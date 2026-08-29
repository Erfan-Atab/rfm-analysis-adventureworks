## Orders without detail lines  
هدف: ایا سفارشی بدون اقلام وجود دارد؟  
دلیل: Foreign Key فقط تضمین میکند هر detail یک Header دارد نه برعکس.  
نتیجه:0  
حکم: pass  

## LinTotal sum versus SubTotal
هدف: ایا `LineTotal` هر سفارش با `SubTotal` در Heather برابر است؟  
دلیل: چون تعریف Monetary روی SUM(LineTotal) بنا شده در صورت برابر نبودن درک از رابطه جداول ممکن بود غلط باشد.  
حکم: pass  

## Non-positive values in monetary columns
بررسی مقادیر صفر یا منفی در ستون های lineTotal, OrderQty, UnitPrice.  
دلیل: ممکن است مقادیر Monetary را کم کند.  
نتیجه: 0  
حکم: Pass  

## Customers with monetary values
هدف: واقعی بودن یا نبودن مشتری های دارای Monetary زیر 5 دلار.  
نتیجه: 570 مشتری که همگی یک سفارش حاوی یک کالا داشته اند.  
حکم: Pass  
تصمیم: در تحلیل باقی میمانند چون سفارش ها معتبر هستند.

## Upper-tail outliers
هفده: تشخیص اینکه ایا مقادیر بالای توزسع مشتری های واقعی هستند یا اینکه داده خراب هستند.  
نتیجه: بالاترین `LineTotal` دز سطح کالا، حدود 27893 دلار از 26 کالا 1192 دلاری است که منطقی میباشد. همچنین تمام ردیف ها توصیف پذیرند و در همه آن ها نیر تخفیف اعمال شده است.  
حکم: Pass  
تصمیم: هیچ رکوردی پاک نمیشوند چون outlier ها مشتری واقعی هستند.  


## Coverage note  


## Limitations
