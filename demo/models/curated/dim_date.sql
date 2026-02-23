with date_spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2020-01-01' as date)",
        end_date="cast('2030-12-31' as date)"
    ) }}
),

final as (
    select
        date_day as date_key,
        date_day as full_date,
        extract(year from date_day) as year,
        extract(month from date_day) as month,
        extract(day from date_day) as day,
        extract(dayofweek from date_day) as day_of_week,
        extract(quarter from date_day) as quarter,
        to_char(date_day, 'MMMM') as month_name,
        to_char(date_day, 'Mon') as month_short,
        to_char(date_day, 'Day') as day_name,
        to_char(date_day, 'Dy') as day_short,
        case when extract(dayofweek from date_day) in (0, 6) then true else false end as is_weekend,
        extract(year from date_day) || '-Q' || extract(quarter from date_day) as year_quarter,
        to_char(date_day, 'YYYY-MM') as year_month
    from date_spine
)

select * from final
