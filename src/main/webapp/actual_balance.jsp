<%@ page import="com.nplekhanov.finance.Balance" %>
<%@ page import="com.nplekhanov.finance.BalanceCorrection" %>
<%@ page import="com.nplekhanov.finance.Formats" %>
<%@ page import="org.springframework.web.context.WebApplicationContext" %>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.NavigableMap" %>
<%@ page import="java.util.TreeSet" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title></title>
    <jsp:include page="css.jsp" />
</head>
<body>
<%@ include file="top.jsp"%>
<a href="summary.jsp?exploreFromSession=true">Summary</a>

<%
    WebApplicationContext context = WebApplicationContextUtils.getRequiredWebApplicationContext(application);

    BalanceCorrection balanceCorrection = context.getBean(BalanceCorrection.class);

    Collection<YearMonth> months = new TreeSet<YearMonth>().descendingSet();
    for (int i = 0; i < 24; i ++) {
        months.add(YearMonth.now().minusMonths(i));
    }

    Long userId = (Long) session.getAttribute("userId");
    NavigableMap<YearMonth, Balance> balances = balanceCorrection.getActualBalances(userId);

    String action = request.getParameter("action");
    if (action != null) {
        if (action.equals("delete")) {
            YearMonth month = YearMonth.parse(request.getParameter("month"), Formats.YEAR_MONTH);
            balanceCorrection.deleteActualBalance(month, userId);
        }
        if (action.equals("add")) {
            YearMonth month = YearMonth.parse(request.getParameter("month"), Formats.YEAR_MONTH);
            long amount = Long.parseLong(request.getParameter("amount"));
            balanceCorrection.addActualBalance(month, amount, userId);
        }
        if (action.equals("update")) {
            YearMonth month = YearMonth.parse(request.getParameter("month"), Formats.YEAR_MONTH);
            long amount = Long.parseLong(request.getParameter("amount"));
            balanceCorrection.updateActualBalance(month, amount, userId);
        }

        response.sendRedirect(request.getContextPath()+request.getServletPath());
        return;
    }

%>
<table>
<%
    for (Balance balance: balances.values()) {
        %> <tr>
            <td><%=Formats.YEAR_MONTH.format(balance.getAt())%></td>
            <form>
                <input type="hidden" name="action" value="update"/>
                <input type="hidden" name="month" value="<%=Formats.YEAR_MONTH.format(balance.getAt())%>"/>
                <td> <input name="amount" value="<%=balance.getAmount()%>"/></td>
                <td><input type="submit" value="Update"/></td>
            </form>
            <td>
                <form style="display: inline" method="post">
                    <input type="hidden" name="action" value="delete"/>
                    <input type="hidden" name="month" value="<%=Formats.YEAR_MONTH.format(balance.getAt())%>"/>
                    <input type="submit" value="Delete"/>
                </form>
            </td>
        </tr> <%
    }
%>
    <tr>
        <form style="display: inline" method="post">
        <td>
            <select name="month">
                <%
                for (YearMonth month: months) {
                    %> <option><%=Formats.YEAR_MONTH.format(month)%></option> <%
                }
                %>
            </select>
        </td>
        <td><input name="amount"/></td>
        <td>
            <input type="hidden" name="action" value="add"/>
            <input type="submit" value="Add"/>
        </td>
        </form>
    </tr>
</table>
</body>
</html>
