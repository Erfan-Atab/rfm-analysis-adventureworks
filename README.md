# RFM Analysis on AdventureWorks

I segmented the customers of the AdventureWorks sample database with the RFM model, using only T-SQL. The full report (in Persian) is in [docs/RFM_Final_Report.pdf](docs/RFM_Final_Report.pdf).

[نسخه فارسی در پایین صفحه](#fa)

## What I did

The data has 19,119 customers with orders, 31,465 orders and about $109.8M of revenue from May 2011 to June 2014. I used `Sales.SalesOrderHeader`, `Sales.SalesOrderDetail` and `Sales.Customer` and built a customer level view called `rfm.vw_CustomerRFM`. Line items are summed to order level before joining, so order counts don't get inflated by the join.

Early in the project I noticed that stores and individual customers behave very differently. Stores order about every 91 days, individuals about every 336 days. So I scored each group separately with `PERCENT_RANK` and `PARTITION BY CustomerType`. I also tested `NTILE` and `CUME_DIST`. `NTILE` didn't work here because 62.86% of individuals have exactly one order, and it had to put identical customers in different scores. After scoring, customers were put into 8 segments with `CASE` rules on the three scores.

## Main results

- Stores are only 3.3% of customers but bring 73.3% of the revenue.
- The Churn Risk segment holds 23.4% of total revenue, which makes it the biggest risk.
- Stores don't order late, they skip whole cycles. Almost all gaps between store orders are 89 to 92 days, and the rest are multiples of that (181, 273, 365...).
- 163 stores have missed more than three cycles. 45 of them account for 79% of the past revenue of this group, so they are the ones worth contacting first.

## Limitations

For individuals the Frequency score is weak, because 92.4% of them have one or two orders, so the model is almost two dimensional for this group. The New Customer label doesn't really fit stores. Monetary is gross revenue, not profit. More details are in the report.

## Files

- `sql/` scripts in run order, 01 to 09. Only 04 creates objects (schema `rfm` and one view), the rest only read.
- `docs/` notes for each stage, all decisions, and the final report (Persian).
- `results/` exported query outputs.

To run it, restore AdventureWorks2022 on SQL Server 2022 and run the scripts in order.

Erfan Atab, [github.com/Erfan-Atab](https://github.com/Erfan-Atab)

---

<a id="fa"></a>
<div dir="rtl">

## تحلیل RFM روی AdventureWorks

مشتریان پایگاه داده AdventureWorks را با مدل RFM و فقط با T-SQL بخش بندی کردم. گزارش کامل در [docs/RFM_Final_Report.pdf](docs/RFM_Final_Report.pdf) است.

### کاری که انجام دادم

داده شامل 19,119 مشتری دارای سفارش، 31,465 سفارش و حدود 109.8 میلیون دلار درآمد از مه 2011 تا ژوئن 2014 است. از جدول های Sales.SalesOrderHeader و Sales.SalesOrderDetail و Sales.Customer استفاده کردم و یک View در سطح مشتری با نام rfm.vw_CustomerRFM ساختم. اقلام سفارش قبل از جوین تا سطح سفارش جمع زده می شوند تا تعداد سفارش ها بیشتر از واقعیت شمرده نشود.

همان اول کار متوجه شدم فروشگاه ها و مشتریان فردی رفتار خیلی متفاوتی دارند. فروشگاه ها تقریبا هر 91 روز سفارش می دهند و افراد تقریبا هر 336 روز. برای همین امتیازدهی هر گروه را جدا و با PERCENT_RANK انجام دادم. NTILE و CUME_DIST را هم امتحان کردم. NTILE جواب نداد چون 62.86 درصد افراد دقیقا یک سفارش دارند و NTILE مجبور بود مشتریان کاملا یکسان را در امتیازهای مختلف بگذارد. بعد از امتیازدهی، مشتریان با قواعد CASE به 8 خوشه تقسیم شدند.

### نتایج اصلی

- فروشگاه ها فقط 3.3 درصد مشتریان هستند ولی 73.3 درصد درآمد را می آورند.
- خوشه در خطر ریزش 23.4 درصد کل درآمد را دارد و بزرگ ترین ریسک است.
- فروشگاه ها سفارش را عقب نمی اندازند بلکه یک چرخه کامل را رد می کنند. تقریبا همه فاصله های سفارش فروشگاه ها 89 تا 92 روز است و بقیه مضرب همین عددند.
- 163 فروشگاه بیش از سه چرخه سفارش نداده اند. 45 تا از آن ها 79 درصد درآمد گذشته این گروه را دارند و اول باید سراغ همین ها رفت.

### محدودیت ها

برای مشتریان فردی امتیاز Frequency ضعیف است، چون 92.4 درصد آن ها یک یا دو سفارش دارند و مدل در این گروه تقریبا دوبعدی است. برچسب مشتری جدید برای فروشگاه ها درست نیست. Monetary درآمد ناخالص است نه سود. جزئیات بیشتر در گزارش آمده.

### فایل ها

- پوشه sql اسکریپت ها به ترتیب اجرا از 01 تا 09. فقط فایل 04 شی می سازد (Schema با نام rfm و یک View) و بقیه فقط می خوانند.
- پوشه docs یادداشت هر مرحله، همه تصمیمات و گزارش نهایی.
- پوشه results خروجی کوئری ها.

برای اجرا، AdventureWorks2022 را روی SQL Server 2022 بازیابی کنید و اسکریپت ها را به ترتیب اجرا کنید.

</div>
