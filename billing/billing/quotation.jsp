<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.*, java.text.DecimalFormat, java.text.SimpleDateFormat, org.json.*" %>
<%
request.setCharacterEncoding("UTF-8");

String customerName = request.getParameter("customerName");
String customerPhone = request.getParameter("customerPhone");
String extraDiscStr = request.getParameter("extraDisc");
String priceTotalStr = request.getParameter("priceTotal");
String discountTotalStr = request.getParameter("discountTotal");
String payableAmountStr = request.getParameter("payableAmount");
String itemsJson = request.getParameter("items");

if (itemsJson == null || itemsJson.trim().isEmpty()) {
    out.print("Error: No items to print estimate");
    return;
}

if (customerName == null || customerName.trim().isEmpty()) customerName = "-";
if (customerPhone == null || customerPhone.trim().isEmpty()) customerPhone = "-";

double extraDisc = 0;
double priceTotal = 0;
double prodDisc = 0;
double payable = 0;

try { if (extraDiscStr != null && !extraDiscStr.trim().isEmpty()) extraDisc = Double.parseDouble(extraDiscStr); } catch (Exception ignored) {}
try { if (priceTotalStr != null && !priceTotalStr.trim().isEmpty()) priceTotal = Double.parseDouble(priceTotalStr); } catch (Exception ignored) {}
try { if (discountTotalStr != null && !discountTotalStr.trim().isEmpty()) prodDisc = Double.parseDouble(discountTotalStr); } catch (Exception ignored) {}
try { if (payableAmountStr != null && !payableAmountStr.trim().isEmpty()) payable = Double.parseDouble(payableAmountStr); } catch (Exception ignored) {}

JSONArray items;
try {
    items = new JSONArray(itemsJson);
} catch (Exception e) {
    out.print("Error: Invalid estimate items");
    return;
}

if (items.length() == 0) {
    out.print("Error: No items to print estimate");
    return;
}

SimpleDateFormat dateFmt = new SimpleDateFormat("dd-MM-yyyy");
SimpleDateFormat timeFmt = new SimpleDateFormat("hh:mm a");
Date now = new Date();
String quotDate = dateFmt.format(now);
String quotTime = timeFmt.format(now);

DecimalFormat df = new DecimalFormat("0.00");

double totalQty = 0;
double calcItemTotal = 0;
double calcItemDisc = 0;

for (int i = 0; i < items.length(); i++) {
    JSONObject item = items.getJSONObject(i);
    totalQty += item.optDouble("qty", 0);
    calcItemTotal += item.optDouble("total", 0);
    calcItemDisc += item.optDouble("discount", 0);
}

if (priceTotal <= 0) priceTotal = calcItemTotal + calcItemDisc;
if (prodDisc <= 0) prodDisc = calcItemDisc;
if (payable <= 0) payable = Math.max(0, priceTotal - prodDisc - extraDisc);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Estimate</title>
    <style>
        @page { size: A5; margin: 8mm; }
        body { font-family: Arial, sans-serif; font-size: 13px; margin: 0; padding: 4px; color: #000; }
        .container { width: 100%; }
        .dash-sep { border: none; border-top: 1px dashed #000; margin: 4px 0; }
        .title-row { display: flex; justify-content: space-between; align-items: flex-start; font-size: 13px; margin: 4px 0; }
        .quot-title { font-size: 18px; font-weight: bold; text-align: center; text-transform: uppercase; flex: 1; }
        .quot-table { width: 100%; border-collapse: collapse; table-layout: fixed; font-size: 13px; }
        .quot-table th { text-align: left; padding: 3px 4px; border-bottom: 1px dashed #000; border-top: 1px dashed #000; font-weight: bold; white-space: nowrap; }
        .quot-table td { padding: 3px 4px; vertical-align: top; }
        .quot-table .num { text-align: right; }
        .quot-table .ctr { text-align: center; }
        .quot-table tfoot td { border-top: 1px dashed #000; font-weight: bold; }
        .summary-table { width: 65%; margin-left: auto; font-size: 13px; border-collapse: collapse; margin-top: 3px; }
        .summary-table td { padding: 3px 5px; font-weight: bold; }
        .summary-table .val { text-align: right; }
        .net-row td { font-weight: bold; font-size: 15px; border-top: 1px dashed #000; }
        .thank-you { text-align: center; font-size: 13px; font-weight: bold; margin-top: 8px; }
        @media print { body { padding: 0; } }
    </style>
    <script>
        window.onload = function() { window.print(); };
        window.onafterprint = function() { window.close(); };
    </script>
</head>
<body>
<div class="container">
    <div class="title-row">
        <div style="line-height:1.7;">
            <div>Customer: <%= customerName %></div>
            <% if (!customerPhone.equals("-") && !customerPhone.trim().isEmpty()) { %>
            <div>Phone: <%= customerPhone %></div>
            <% } %>
        </div>
        <div class="quot-title">ESTIMATE</div>
        <div style="text-align:right; line-height:1.7;">
            <div>Date: <%= quotDate %></div>
            <div>Time: <%= quotTime %></div>
        </div>
    </div>

    <table class="quot-table">
        <colgroup>
            <col style="width:7%">
            <col style="width:auto">
            <col style="width:13%">
            <col style="width:13%">
            <col style="width:13%">
            <col style="width:15%">
        </colgroup>
        <thead>
            <tr>
                <th class="ctr">Sno</th>
                <th>Description</th>
                <th class="num">Rate</th>
                <th class="num">Qty</th>
                <th class="num">Disc</th>
                <th class="num">Amount</th>
            </tr>
        </thead>
        <tbody>
            <%
            int rowNum = 1;
            for (int i = 0; i < items.length(); i++) {
                JSONObject item = items.getJSONObject(i);
                String prodName = item.optString("name", "");
                double qty = item.optDouble("qty", 0);
                double price = item.optDouble("price", 0);
                double disc = item.optDouble("discount", 0);
                double itemTotal = item.optDouble("total", 0);
            %>
            <tr>
                <td class="ctr"><%= rowNum++ %></td>
                <td><%= prodName %></td>
                <td class="num"><%= df.format(price) %></td>
                <td class="num"><%= df.format(qty) %></td>
                <td class="num"><%= df.format(disc) %></td>
                <td class="num"><%= df.format(itemTotal) %></td>
            </tr>
            <% } %>
        </tbody>
        <tfoot>
            <tr>
                <td colspan="3">total.Qty :</td>
                <td class="num"><%= df.format(totalQty) %></td>
                <td colspan="2"></td>
            </tr>
        </tfoot>
    </table>
    <hr class="dash-sep">
    <table class="summary-table">
        <tr><td>Total</td><td>:</td><td class="val"><%= df.format(priceTotal) %></td></tr>
        <% if (prodDisc > 0) { %><tr><td>Item Disc</td><td>:</td><td class="val"><%= df.format(prodDisc) %></td></tr><% } %>
        <% if (extraDisc > 0) { %><tr><td>Extra Disc</td><td>:</td><td class="val"><%= df.format(extraDisc) %></td></tr><% } %>
        <tr class="net-row"><td>PAYABLE</td><td>:</td><td class="val"><%= df.format(payable) %></td></tr>
    </table>
    <hr class="dash-sep">
    <div class="thank-you">Thank You !.. Visit Again</div>
</div>
</body>
</html>
