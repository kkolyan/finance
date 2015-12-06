<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.getSession().removeAttribute("userId");
    response.sendRedirect("login.jsp");
%>