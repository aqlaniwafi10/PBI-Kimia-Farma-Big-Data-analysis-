CREATE OR REPLACE TABLE Rakamin_PBI.base_table AS
SELECT
    j.transaction_id,
    j.date,
    j.customer_name,
    j.branch_id,
    b.branch_name,
    b.kota,
    b.provinsi,
    p.product_id,
    p.product_name,
    p.product_category,
    j.price AS original_price,
    j.discount_percentage,
    (j.price * (1 - j.discount_percentage / 100)) AS final_price,
    j.rating AS transaction_rating,
    b.rating AS branch_rating,
    i.opname_stock
FROM Rakamin_PBI.kf_final_transaction j
LEFT JOIN Rakamin_PBI.kf_kantor_cabang b
    ON j.branch_id = b.branch_id
LEFT JOIN Rakamin_PBI.kf_product p
    ON j.product_id = p.product_id
LEFT JOIN Rakamin_PBI.kf_inventory i
    ON j.product_id = i.product_id AND j.branch_id = i.branch_id;

CREATE OR REPLACE TABLE Rakamin_PBI.analisa_transaksi AS
SELECT
    j.transaction_id,
    j.date,
    j.branch_id,
    b.branch_name,
    b.kota,
    b.provinsi,
    b.rating AS rating_cabang,
    j.customer_name,
    j.product_id,
    p.product_name,
    j.price AS actual_price,
    j.discount_percentage,
    -- Menentukan persentase gross laba berdasarkan kategori harga
    CASE 
        WHEN j.price <= 50000 THEN 0.10
        WHEN j.price > 50000 AND j.price <= 100000 THEN 0.15
        WHEN j.price > 100000 AND j.price <= 300000 THEN 0.20
        WHEN j.price > 300000 AND j.price <= 500000 THEN 0.25
        ELSE 0.30
    END AS persentase_gross_laba,
    -- Harga setelah diskon
    (j.price * (1 - j.discount_percentage / 100)) AS nett_sales,
    -- Perhitungan nett profit (nett sales * persentase laba)
    (j.price * (1 - j.discount_percentage / 100)) * 
    CASE 
        WHEN j.price <= 50000 THEN 0.10
        WHEN j.price > 50000 AND j.price <= 100000 THEN 0.15
        WHEN j.price > 100000 AND j.price <= 300000 THEN 0.20
        WHEN j.price > 300000 AND j.price <= 500000 THEN 0.25
        ELSE 0.30
    END AS nett_profit,
    j.rating AS rating_transaksi
FROM Rakamin_PBI.kf_final_transaction j
LEFT JOIN Rakamin_PBI.kf_kantor_cabang b
    ON j.branch_id = b.branch_id
LEFT JOIN Rakamin_PBI.kf_product p
    ON j.product_id = p.product_id;
