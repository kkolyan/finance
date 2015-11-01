<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="org.springframework.web.context.WebApplicationContext" %>
<%@ page import="com.nplekhanov.finance.Finances" %>
<%@ page import="com.nplekhanov.finance.Item" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="org.springframework.util.StringUtils" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.Year" %>
<%@ page import="java.time.Month" %>
<%@ page import="java.time.format.TextStyle" %>
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
            background-color: #ebffeb;
        }
        th {
            white-space: nowrap;
            background: #EEE;
            font-size: 11pt;
        }

        .offer-field-type {
            color: #5a0a04;
        }
        .offer-field-subtitle {
            color: #2634a6;
        }

        td.amount {
            text-align: right;
            font: 'Courier New';
        }

        th.balance {
            text-align: right;
            font-size: 10pt;
            font-weight: normal;
        }

        th.annual {
            text-align: right;
            font-weight: normal;
        }
        * {
            white-space: nowrap;
        }
    </style>
</head>
<body>
<%!
    String formatNumber(Long o) {
        if (o.equals(0L)) {
            return "";
        }
        return String.format("%,d", o);
    }
%>
<%
    WebApplicationContext context = WebApplicationContextUtils.getRequiredWebApplicationContext(application);
    Finances finances = context.getBean(Finances.class);
    Item root = finances.loadRoot();

    Collection<YearMonth> range = root.calculateRange();
    Collection<Year> years = new TreeSet<Year>();
    for (YearMonth month: range) {
        years.add(Year.of(month.getYear()));
    }

    Collection<String> names = new TreeSet<String>();
    String[] itemParams = request.getParameterValues("explore");
    if (itemParams != null) {
        Collections.addAll(names, itemParams);
    }

    List<Item> items = root.explore(names);

    int maxDepth = 0;
    for (Item item: items) {
        maxDepth = Math.max(maxDepth, item.getPath().size());
    }

    %> <table> <%
    %><tr></tr> <%
    %> <tr><th colspan="<%=maxDepth + 1%>"></th><%
    for (Year year: years) {
        for (Month month: Month.values()) {
            %> <th><%=month.getDisplayName(TextStyle.FULL_STANDALONE, request.getLocale())%></th> <%
        }
        %> <th><%=year%></th> <%
    }
    %></tr><%
    long balance = finances.loadInitialBalance();
    %> <tr><th class="balance" colspan="<%=maxDepth + 1%>"><%=formatNumber(balance)%></th><%
        for (Year year: years) {
            for (Month month: Month.values()) {
                long amount = root.calculateAmount(YearMonth.of(year.getValue(), month));
                balance += amount;
                %> <th class="balance"><%= formatNumber(balance)%></th> <%
            }
            %> <th class="balance annual"><%=formatNumber(balance)%></th> <%
        }
    %></tr><%
    Item last = null;
    for (int i = 0; i < items.size(); i ++) {
        Item item = items.get(i);
        %> <tr><%
        Collection<String> toExplore = new HashSet<String>();
        toExplore.addAll(names);

        if (names.contains(item.getName())) {
            toExplore.remove(item.getName());
        } else {
            toExplore.add(item.getName());
        }

        Collection<String> entries = new ArrayList<String>();
        for (String name: toExplore) {
            entries.add("explore="+ URLEncoder.encode(name,"utf8"));
        }
        String params = StringUtils.collectionToDelimitedString(entries, "&");
        if (last != null && last == item.getParent()) {

            int n = 0;
            for (int j = i; j < items.size() && items.get(j).getPath().size() >= item.getPath().size(); j ++) {
                n ++;
            }

            %> <td rowspan="<%=n%>"></td> <%
        }
        %><td colspan="<%=maxDepth-item.getPath().size() + 1%>"> <a href="balance.jsp?<%=params%>"><%=item.getName()%></a></td> <%

        for (Year year: years) {
            long annual = 0;
            for (Month month: Month.values()) {
                long amount = item.calculateAmount(YearMonth.of(year.getValue(), month));
                %><td class="amount<% if (amount > 0) {%> positive<%}%>"><%=formatNumber(amount)%></td><%
                annual += amount;
            }
            %> <th class="annual"><%=formatNumber(annual)%></th> <%
        }
        %></tr><%
        last = item;
    }
    %> </table> <%

%>
</body>
</html>
