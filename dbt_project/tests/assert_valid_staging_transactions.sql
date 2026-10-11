-- Custom singular test:
-- Tidak boleh ada transaksi invalid pada model staging.

select
    transaction_id,
    transaction_datetime,
    quantity,
    unit_price,
    rating
from {{ ref('stg_transactions') }}
where transaction_id is null
   or transaction_datetime is null
   or quantity <= 0
   or unit_price is null
   or unit_price < 0
   or (
       rating is not null
       and rating not between 1 and 5
   )
