<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="org.springframework.web.context.WebApplicationContext" %>
<%@ page import="com.nplekhanov.finance.*" %>
<%@ page import="static com.nplekhanov.finance.Escaping.*" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.LocalDate" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%

    WebApplicationContext context = WebApplicationContextUtils.getRequiredWebApplicationContext(application);
    Finances finances = context.getBean(Finances.class);
    long transferId = Long.parseLong(request.getParameter("transferId"));
    NamedTransfer transfer = finances.getTransfer(transferId);

    if (request.getMethod().equalsIgnoreCase("POST")) {
        long amount = Long.parseLong(request.getParameter("amount"));
        LocalDate at = LocalDate.parse(request.getParameter("at"), Formats.DATE_TIME);
        finances.modifyTransfer(transferId, at, amount);
        response.sendRedirect(request.getContextPath()+request.getServletPath()+"?"+request.getQueryString());
        return;
    }
%>
<html>
<head>
    <title></title>
</head>
<body>

<fieldset>
    <legend><%=safeHtml(transfer.getName())%> #<%=transferId%></legend>
    <form method="post">
        <input type="hidden" name="transferId" value="<%=transferId%>">
        <label>
            At (<%= Formats.DATE_TIME_PATTERN %>)
            <input name="at" value="<%= transfer.getTransfer().getDate().format(Formats.DATE_TIME)%>"/>
        </label>
        <label>
            Amount
            <input name="amount" value="<%=transfer.getTransfer().getAmount()%>"/>
        </label>
        <input type="submit" value="Save"/>
    </form>
</fieldset>

</body>
</html>
