update aliss15a_daily_words dw
inner join
(
    Select dw_1.w_id as w_id,dw_1.date as date,sum(dw_2.relative_freq)/5 as filt_freq from aliss15a_daily_words dw_1 
    inner join aliss15a_daily_words dw_2
    on
    (
        dw_1.date between "2015-03-01" and "2015-03-31" and
        dw_2.date between dw_1.date - interval 5 day and dw_1.date
    )
    group by dw_1.w_id,dw_1.date
) as filt_dw
on filt_dw.w_id = dw.w_id and filt_dw.date = dw_date

set lin_filt_freq=dw.filt_freq
