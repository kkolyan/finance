<%@ page import="com.nplekhanov.finance.Users" %>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="com.nplekhanov.finance.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Users users = WebApplicationContextUtils.getRequiredWebApplicationContext(application).getBean(Users.class);
    Long theUserId = (Long) request.getSession().getAttribute("userId");
    if (theUserId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    User user = users.getUser(theUserId);
%>
<div style="float: right;">
    <b><%=user.getName()%></b>
    <a href="logout.jsp">exit</a>
</div>