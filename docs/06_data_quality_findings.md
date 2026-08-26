## Orders without detail lines  
هدف: ایا سفارشی بدون اقلام وجود دارد؟  
دلیل: Foreign Key فقط تضمین میکند هر detail یک Header دارد نه برعکس.  
نتیجه:0  
حکم: pass  

## LinTotal sum versus SubTotal
هدف: ایا `LineTotal` هر سفارش با `SubTotal` در Heather برابر است؟  
دلیل: چون تعریف Monetary روی SUM(LineTotal) بنا شده در صورت برابر نبودن درک از رابطه جداول ممکن بود غلط باشد.  
حکم: pass  

## Coverage note  


## Limitations
