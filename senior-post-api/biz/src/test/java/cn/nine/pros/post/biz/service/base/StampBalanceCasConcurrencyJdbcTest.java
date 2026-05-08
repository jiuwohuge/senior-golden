package cn.nine.pros.post.biz.service.base;

import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicInteger;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * JDBC 复现 {@link cn.nine.pros.post.biz.service.base.impl.StampAccountServiceImpl} 的 CAS 语义：
 * 先读余额，再 {@code UPDATE ... WHERE stamps_balance = 读到的旧值}。
 * 高并发下最终余额不得为负，且等于初始值减去成功次数。
 */
class StampBalanceCasConcurrencyJdbcTest {

    private static String memUrl(String name) {
        return "jdbc:h2:mem:" + name + ";MODE=PostgreSQL;DB_CLOSE_DELAY=-1";
    }

    @Test
    void hundredConcurrentSingleDeductions_finalBalanceMatchesSuccessCount() throws Exception {
        final String url = memUrl("cas_t1_" + UUID.randomUUID().toString().replace('-', '_'));
        try (Connection setup = DriverManager.getConnection(url)) {
            setup.createStatement().execute(
                    "CREATE TABLE bu_user (id BIGINT PRIMARY KEY, stamps_balance INT NOT NULL, "
                            + "del_flag BOOLEAN NOT NULL DEFAULT FALSE)");
            setup.createStatement().execute("INSERT INTO bu_user(id, stamps_balance, del_flag) VALUES (1, 40, FALSE)");
        }

        int threads = 100;
        ExecutorService pool = Executors.newFixedThreadPool(32);
        CountDownLatch start = new CountDownLatch(1);
        CountDownLatch done = new CountDownLatch(threads);
        AtomicInteger oks = new AtomicInteger();
        for (int i = 0; i < threads; i++) {
            pool.submit(() -> {
                try {
                    start.await();
                    if (tryDecrementOnce(url)) {
                        oks.incrementAndGet();
                    }
                } catch (Exception e) {
                    throw new RuntimeException(e);
                } finally {
                    done.countDown();
                }
            });
        }
        start.countDown();
        assertThat(done.await(30, TimeUnit.SECONDS)).isTrue();
        pool.shutdown();

        try (Connection c = DriverManager.getConnection(url);
             PreparedStatement s = c.prepareStatement("SELECT stamps_balance FROM bu_user WHERE id=1");
             ResultSet rs = s.executeQuery()) {
            assertThat(rs.next()).isTrue();
            int fin = rs.getInt(1);
            assertThat(fin).isGreaterThanOrEqualTo(0);
            assertThat(fin).isEqualTo(40 - oks.get());
        }
    }

    @Test
    void manyThreadsOversubscribe_initial10_neverNegative() throws Exception {
        final String url = memUrl("cas_t2_" + UUID.randomUUID().toString().replace('-', '_'));
        try (Connection setup = DriverManager.getConnection(url)) {
            setup.createStatement().execute(
                    "CREATE TABLE bu_user (id BIGINT PRIMARY KEY, stamps_balance INT NOT NULL, "
                            + "del_flag BOOLEAN NOT NULL DEFAULT FALSE)");
            setup.createStatement().execute("INSERT INTO bu_user(id, stamps_balance, del_flag) VALUES (1, 10, FALSE)");
        }

        int threads = 200;
        ExecutorService pool = Executors.newFixedThreadPool(64);
        CountDownLatch start = new CountDownLatch(1);
        CountDownLatch done = new CountDownLatch(threads);
        AtomicInteger oks = new AtomicInteger();
        for (int i = 0; i < threads; i++) {
            pool.submit(() -> {
                try {
                    start.await();
                    if (tryDecrementOnce(url)) {
                        oks.incrementAndGet();
                    }
                } catch (Exception e) {
                    throw new RuntimeException(e);
                } finally {
                    done.countDown();
                }
            });
        }
        start.countDown();
        assertThat(done.await(60, TimeUnit.SECONDS)).isTrue();
        pool.shutdown();

        try (Connection c = DriverManager.getConnection(url);
             PreparedStatement s = c.prepareStatement("SELECT stamps_balance FROM bu_user WHERE id=1");
             ResultSet rs = s.executeQuery()) {
            assertThat(rs.next()).isTrue();
            int fin = rs.getInt(1);
            assertThat(fin).isGreaterThanOrEqualTo(0);
            assertThat(oks.get()).isLessThanOrEqualTo(10);
            assertThat(fin).isEqualTo(10 - oks.get());
        }
    }

    private static boolean tryDecrementOnce(String url) throws Exception {
        try (Connection c = DriverManager.getConnection(url)) {
            c.setAutoCommit(true);
            int old;
            try (PreparedStatement q = c.prepareStatement(
                    "SELECT stamps_balance FROM bu_user WHERE id=1 AND del_flag=FALSE");
                 ResultSet rs = q.executeQuery()) {
                if (!rs.next()) {
                    return false;
                }
                old = rs.getInt(1);
            }
            if (old < 1) {
                return false;
            }
            try (PreparedStatement u = c.prepareStatement(
                    "UPDATE bu_user SET stamps_balance=? WHERE id=1 AND stamps_balance=? AND del_flag=FALSE")) {
                u.setInt(1, old - 1);
                u.setInt(2, old);
                return u.executeUpdate() == 1;
            }
        }
    }
}
