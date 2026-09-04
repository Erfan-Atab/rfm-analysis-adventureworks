## بررسی NTILE برای هر سه شاخص
| مرز کوینتایل | Individual | Store with rep |
| ------------------------------------ | ------------- | ------------- |
| 20٪                                  | Frequency = 1 | Frequency = 4 |
| 40٪                                  | Frequency = 1 | Frequency = 4 |
| 60٪                                  | Frequency = 1 | Frequency = 7 |
| 80٪                                  | Frequency = 2 | Frequency = 8 |  

دسته Individual با یک دسته 62.86 درصد و Store با دو دسته 37.17 و 23.46 درصد. 


هدف: اندازه‌گیری سهم پرتکرارترین مقدار واحد و تعداد مقادیر متمایز در دو شاخص باقی‌مانده، به تفکیک نوع مشتری
چرا؟ بررسی قبلی فقط شامل Frequancy بود و تحلیل توزیع این دو برای انتخاب Window Function ضروری است.  
نتیجه:  
TopValue گروه Store در Recency	61، برابر MinRecency  
DistinctValueCount هر شاخص	کمتر از جمعیت گروه در هر چهار حالت  
TopValue گروه Individual در Monetary	4.99، از گروه زیر ۵ دلار  
TopValueSharePct هر شاخص	همه کمتر از ۱۰۰  
حکم: Pass برای سه ترکیب. Fail برای Recency در گروه Store with rep با ۲۸.۱۹ درصد  
تصمیم: `NTILE` برای Recency در گروه Store رد میشود.  
