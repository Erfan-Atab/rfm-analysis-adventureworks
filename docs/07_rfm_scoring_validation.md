## Row count preservation
هدف: اطمینان از تغییر نکردن لایه امتیاز دهی
چرا؟ کوئری سه لایه دارد و امکان خطا وجود دارد
نتیجه: 19119
حکم:Pass  

## Score range and NULL check
هدف: اطمینان از بدون امتیاز ها در 1 تا 5
چرا؟ CASE بدون ELSE در صورت نبودن پوشش درست بی صدا NUUL میدهد  
حکم: Pass  

## Score level coverage
هدف: شمارش مشتریان هر امتیاز به تفکیک گروه و امتیاز برای پیدا کردن سطوح خالی  
چرا؟ `PERCENT_RANK` توده های یکسان را نمیشکند پس ممکن است بعضی سطوح به هیچ مشتری نرسد.  
نتیجه" 526 ردیف از 30 ردیف ممکن
حکم: Fail  
تصمیم: سطوح خالی حذف نمیشوند و در مراحل بعدی به صورت خوشه های خالی نشان داده میشوند.  
| CustomerType | Metric    | Score | CustomerCount |
| ------------ | --------- | ----- | ------------- |
| Individual   | Frequency | 1     | 11,619        |
| Individual   | Frequency | 4     | 5,454         |
| Individual   | Frequency | 5     | 1,411         |
| Individual   | Monetary  | 1     | 4,124         |
| Individual   | Monetary  | 2     | 3,271         |
| Individual   | Monetary  | 3     | 3,716         |
| Individual   | Monetary  | 4     | 3,676         |
| Individual   | Monetary  | 5     | 3,697         |
| Individual   | Recency   | 1     | 3,721         |
| Individual   | Recency   | 2     | 3,731         |
| Individual   | Recency   | 3     | 3,691         |
| Individual   | Recency   | 4     | 3,653         |
| Individual   | Recency   | 5     | 3,688         |
| Store with rep | Frequency | 1   | 323           |
| Store with rep | Frequency | 3   | 71            |
| Store with rep | Frequency | 4   | 149           |
| Store with rep | Frequency | 5   | 92            |
| Store with rep | Monetary  | 1   | 127           |
| Store with rep | Monetary  | 2   | 127           |
| Store with rep | Monetary  | 3   | 127           |
| Store with rep | Monetary  | 4   | 127           |
| Store with rep | Monetary  | 5   | 127           |
| Store with rep | Recency   | 1   | 142           |
| Store with rep | Recency   | 2   | 135           |
| Store with rep | Recency   | 3   | 179           |
| Store with rep | Recency   | 4   | 179           |  

سطوح خالی:  
| گروه | شاخص    | سطوح غایب
| ---- | ------- | --------- |
| Individual | Frequency | 2 & 3 |
| Store with rep | Frequency | 2 |
| Store with rep | Recency | 5 |  

## Ceilling analysis of Recency percentile in the store group
هدف: پیدا کردن دلیل خالی بودن امتیاز 5 در Recency در پروه store.  
نتیجه: 32 مقدار متفاوت . بالاترین مقدار گروه مال Recency = 61 هست با 179 مشتری و RPercentile = 0.7192.  
حکم: فرضیه تایید شد.  
تصمیم: امتیاز 5 در اینجا نیست و این محدودیت روشه نه خطای داده.  

## Recency direction test
هدف: اطمینان از اینه امتیار بالای Recency به مشتری تازه تز اختصاص پیدا کرده.  
حکم: Pass  

## Limitations  
بررسی ۶.۴ فقط جهت Recency را آزمود. جهت Frequency و Monetary آزمون مستقلی نگرفت، چون هر دو صعودی و هم‌جهت با شهود عادی‌اند و خطای احتمالی‌شان کمتر پنهان می‌ماند.  

