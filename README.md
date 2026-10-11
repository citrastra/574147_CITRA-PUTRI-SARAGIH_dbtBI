# DBT & BI Dashboard — Beauty E-Commerce

## Deskripsi
Project ini melanjutkan pipeline Apache Airflow menggunakan dbt Core,
DuckDB, dan Power BI untuk membersihkan data serta menganalisis penjualan
e-commerce produk kecantikan.

## Arsitektur
Airflow ETL -> DuckDB raw -> DBT Staging -> DBT Datamart -> Power BI

## Model DBT
- stg_transactions: membersihkan dan memvalidasi transaksi.
- stg_products: membersihkan master produk.
- mart_sales_analysis: agregasi penjualan berdasarkan bulan, kategori,
  kanal penjualan, dan kota.

Staging menggunakan materialisasi view, sedangkan Datamart menggunakan table.

## Data Quality
Project memiliki generic tests dan custom singular test.
Pada eksekusi terakhir, 3 model berhasil dijalankan dan 16 data tests lulus.
Output Airflow berisi 970 transaksi valid.

## Menjalankan DBT
Aktifkan environment Python, lalu jalankan:

    cd dbt_project
    dbt debug --profiles-dir . --project-dir .
    dbt run --profiles-dir . --project-dir .
    dbt test --profiles-dir . --project-dir .
    dbt docs generate --profiles-dir . --project-dir .

Untuk membuka dokumentasi:

    dbt docs serve --profiles-dir . --project-dir . --port 8081

Buka http://localhost:8081 di browser.

## Dashboard
Dashboard utama berada di:
dashboard/574147_Citra_Putri_Saragih_DBT_BI_DuckDB.pbix

Dashboard menggunakan konektor DuckDB dengan mode Import.
Komputer reviewer perlu mengatur konektor dan lokasi database lokal
sesuai lingkungan masing-masing.

## Dokumentasi
Screenshot lineage DBT tersedia di docs/dbt_lineage_graph.png.
Laporan akhir menjelaskan arsitektur, data quality, dashboard,
kendala, solusi, dan kesimpulan.
