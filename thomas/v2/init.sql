alter table aliss15a_windows_of_r add lin_filt_freq float;

update aliss15a_windows_of_r r
inner join daily_words dw 
on r.w_id=dw.w_id and r.date = dw.date
set lin_filt_freq=r.window8/dw.freq;
