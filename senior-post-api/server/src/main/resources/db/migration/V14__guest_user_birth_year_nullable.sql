-- 静默 guest 无资料：birth_year 允许空，待绑定/补全资料后再填
ALTER TABLE bu_user ALTER COLUMN birth_year DROP NOT NULL;
