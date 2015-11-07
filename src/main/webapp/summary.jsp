<%@ page import="org.springframework.util.StringUtils" %>
<%@ page import="org.springframework.web.context.WebApplicationContext" %>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="java.time.Month" %>
<%@ page import="java.time.Year" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.time.format.TextStyle" %>
<%@ page import="java.util.*" %>
<%@ page import="com.nplekhanov.finance.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title></title>
    <style>
        table {
            border-collapse: collapse;
        }
        td,th {
            border: 1px solid #CCC;
            padding: 1px 5px;
            /*min-width: 240px;*/
        }

        td.positive {
            background-color: rgb(235, 255, 235);
        }
        td.current-month {
            background-color: rgb(255, 250, 236);
        }
        td.positive.current-month {
            background-color: rgb(240, 253, 235);
        }
        th.current-month {
            background-color: rgb(230, 227, 220);
        }
        th {
            white-space: nowrap;
            background: #EEE;
            font-size: 11pt;
        }

        th.month {
            font-weight: normal;
        }

        .offer-field-type {
            color: #5a0a04;
        }
        .offer-field-subtitle {
            color: #2634a6;
        }
        .transfer-actual { color: black; }
        .transfer-planned { color: #a3a3a3; font-weight: 300; }
        .transfer-estimated { color: #7c96d1 }
        .transfer-corrected { color: #485dc4; font-weight: 300; }
        .transfer-mixed { color: #8a0b05; font-weight: 300; }

        td.amount {
            text-align: right;
            font: 'Courier New';
        }

        th.balance {
            text-align: right;
            font-size: 10pt;
            font-weight: normal;
        }

        th.balance_actual {
            font-weight: bold;
        }

        th.annual {
            text-align: right;
            font-weight: normal;
        }
        * {
            white-space: nowrap;
        }

        a.edit-item {
            color: #CCC;
        }
    </style>
</head>
<body>
<jsp:include page="top.jsp"/>
<%!
    String formatNumber(Long o) {
        if (o.equals(0L)) {
            return "";
        }
        return String.format("%,d", o);
    }

    String getClassByAmountTypes(Collection<AmountType> amountTypes) {
        if (amountTypes.isEmpty()) {
            return "";
        }
        if (amountTypes.size() == 1) {
            return "transfer-"+amountTypes.iterator().next().name().toLowerCase();
        }
        return "transfer-mixed";
    }
%>
<%
    WebApplicationContext context = WebApplicationContextUtils.getRequiredWebApplicationContext(application);
    Finances finances = context.getBean(Finances.class);
    BalanceCorrection correction = context.getBean(BalanceCorrection.class);
    Item root = finances.loadRoot();

    LocalDate today = LocalDate.now();

    Collection<YearMonth> range = root.calculateRange();
    Collection<Year> years = new TreeSet<>();
    for (YearMonth month: range) {
        years.add(Year.of(month.getYear()));
    }

    Collection<Long> names = new TreeSet<>();
    boolean exploreFromSession = "true".equals(request.getParameter("exploreFromSession"));
    String[] itemParams;
    if (exploreFromSession) {
        itemParams = (String[]) session.getAttribute("explore");
    } else {
        itemParams = request.getParameterValues("explore");
        session.setAttribute("explore", itemParams);
    }
    if (itemParams != null) {
        for (String param: itemParams) {
            names.add(Long.parseLong(param));
        }
    }

    List<? extends Item> items = ((Group)root).explore(names);

    int maxDepth = 0;
    for (Item item: items) {
        maxDepth = Math.max(maxDepth, item.getPath().size());
    }

    %> <table> <%
    %><tr></tr> <%
    %> <tr><th colspan="<%=maxDepth + 1%>"></th><%
    for (Year year: years) {
        for (Month month: Month.values()) {
            boolean currentMonth = today.getYear() == year.getValue() && today.getMonth() == month;
            %> <th class="month<% if (currentMonth) {%> current-month<%}%>"><%=month.getDisplayName(TextStyle.FULL_STANDALONE, request.getLocale())%></th> <%
        }
        %> <th class="year"><%=year%></th> <%
    }
    %></tr><%
    NavigableMap<YearMonth, Balance> balances = correction.getActualBalances();
    long balance = balances.firstEntry().getValue().getAmount();
    %> <tr><th class="balance balance_actual" colspan="<%=maxDepth + 1%>"><%=formatNumber(balance)%></th><%
        for (Year year: years) {
            for (Month month: Month.values()) {
                boolean currentMonth = today.getYear() == year.getValue() && today.getMonth() == month;
                long amount = 0;
                for (AmountType amountType: AmountType.values()) {
                    amount += root.calculateAmount(YearMonth.of(year.getValue(), month), amountType);
                }
                balance += amount;
                boolean actual = balances.containsKey(YearMonth.of(year.getValue(), month));
                %> <th class="balance<%if (actual) {%> balance_actual<%}%><% if (currentMonth) {%> current-month<%}%>"><%= formatNumber(balance)%></th> <%
            }
            %> <th class="balance annual"><%=formatNumber(balance)%></th> <%
        }
    %></tr><%
    Item last = null;
    for (int i = 0; i < items.size(); i ++) {
        Item item = items.get(i);
        %> <tr><%
        Collection<Long> toExplore = new HashSet<Long>();
        toExplore.addAll(names);

        if (names.contains(item.getItemId())) {
            toExplore.remove(item.getItemId());
        } else {
            toExplore.add(item.getItemId());
        }

        if (last != null && last == item.getParent()) {

            int n = 0;
            for (int j = i; j < items.size() && items.get(j).getPath().size() >= item.getPath().size(); j ++) {
                n ++;
            }

            %> <td rowspan="<%=n%>"></td> <%
        }
        %><td colspan="<%=maxDepth-item.getPath().size() + 1%>" title="<%=Escaping.safeHtml(item)%>">
            <%

                if (item instanceof Group) {
                    Collection<String> entries = new ArrayList<String>();
                    for (Long itemId: toExplore) {
                        entries.add("explore="+ itemId);
                    }
                    String params = StringUtils.collectionToDelimitedString(entries, "&");
                    %><a href="summary.jsp?<%=params%>"><%=item.getName()%></a><%
                } else {
                    %> <%=item.getName()%> <%
                }

            %>
            <a class="edit-item"
               href="transfer.jsp?transferId=<%=item.getItemId()%>"
               target="_blank">.</a>


        </td> <%

        for (Year year: years) {
            long annual = 0;
            Set<AmountType> annualAmountTypes = EnumSet.noneOf(AmountType.class);
            for (Month month: Month.values()) {
                boolean currentMonth = today.getYear() == year.getValue() && today.getMonth() == month;
                Set<AmountType> amountTypes = EnumSet.noneOf(AmountType.class);
                long amount = 0;
                for (AmountType amountType: AmountType.values()) {
                    long n = item.calculateAmount(YearMonth.of(year.getValue(), month), amountType);
                    if (n != 0) {
                        amount += n;
                        amountTypes.add(amountType);
                        annualAmountTypes.add(amountType);
                    }
                }
                %><td class="amount<% if (amount > 0) {%> positive<%}%> <%=getClassByAmountTypes(amountTypes)%><% if (currentMonth) {%> current-month<%}%>"><%=formatNumber(amount)%></td><%
                annual += amount;
            }
            %> <th class="annual <%=getClassByAmountTypes(annualAmountTypes)%>"><%=formatNumber(annual)%></th> <%
        }
        %></tr><%
        last = item;
    }
    %> </table> <%

%>
</body>
</html>
