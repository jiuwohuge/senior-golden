package cn.nine.pros.post.client.common.enums;

/**
 * 举报处理状态（与 bu_report.status 对齐）。
 */
public final class ReportHandleStatus {
    public static final int PENDING = 0;
    public static final int HANDLED = 1;
    public static final int REJECTED = 2;

    private ReportHandleStatus() {
    }
}
