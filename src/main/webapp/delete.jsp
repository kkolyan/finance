<%@ page import="com.nplekhanov.finance.Finances" %>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="org.springframework.web.context.WebApplicationContext" %>
<%@ page import="com.nplekhanov.finance.Escaping" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title></title>
    <jsp:include page="css.jsp"/>
</head>
<body>
<%

    WebApplicationContext context = WebApplicationContextUtils.getRequiredWebApplicationContext(application);
    Finances finances = context.getBean(Finances.class);

    Long transferId = Long.parseLong(request.getParameter("transferId"));
    if ("true".equals(request.getParameter("confirm"))) {
        finances.deleteItem(transferId, (Long) session.getAttribute("userId"));
        response.sendRedirect(request.getParameter("parentPage"));
    }
%>
<form method="post">
    <input type="hidden" name="transferId" value="<%=transferId%>"/>
    <input type="hidden" name="confirm" value="true"/>
    <input type="hidden" name="referrer" value="<%=Escaping.safeHtml(request.getParameter("referrer"))%>"/>
    <input type="hidden" name="parentPage" value="<%=Escaping.safeHtml(request.getParameter("parentPage"))%>"/>
    <input type="submit" value="Confirm Delete"/>
</form>
<a href="<%=Escaping.safeHtml(request.getParameter("referrer"))%>">Cancel</a>
</body>
</html>
