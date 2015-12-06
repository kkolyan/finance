

<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="com.nplekhanov.finance.Users" %>
<%@ page import="com.nplekhanov.finance.Invitation" %>
<%@ page import="com.nplekhanov.finance.Escaping" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title></title>
    <jsp:include page="css.jsp"/>
</head>
<body>
<%
    Users users = WebApplicationContextUtils.getRequiredWebApplicationContext(application).getBean(Users.class);
    if (request.getMethod().equalsIgnoreCase("post")) {

        String name = request.getParameter("name");
        String password = request.getParameter("password");
        String password2 = request.getParameter("password2");

        if (!password.equals(password2)) {
            throw new IllegalStateException("password not match");
        }

        users.registerUser(request.getParameter("code"), name, password);

        response.sendRedirect(request.getContextPath()+"/login.jsp?name="+name);
        return;
    }
%>
<form method="post">
    <input type="hidden" name="code" value="<%=Escaping.safeHtml(request.getParameter("code"))%>"/>
    <label>
        Name
        <input name="name"/>
    </label>
    <label>
        Password
        <input type="password" name="password"/>
    </label>
    <label>
        Repeat password
        <input type="password" name="password2"/>
    </label>
    <input type="submit" value="Register"/>
</form>
</body>
</html>
