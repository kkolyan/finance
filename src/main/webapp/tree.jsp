<%@ page import="com.nplekhanov.finance.Finances" %>
<%@ page import="com.nplekhanov.finance.Item" %>
<%@ page import="org.springframework.web.context.WebApplicationContext" %>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ taglib prefix="fin" tagdir="/WEB-INF/tags" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%!
    String getTreeFriendlyPath(Item item) {

        int parentPathLength = item.getPath().size();

        StringBuilder s = new StringBuilder();
        for (int i = 0; i < parentPathLength; i ++) {
            s.append("&nbsp;&nbsp;&nbsp;&nbsp;");
        }
        return s.append(item.getName()).toString();
    }
%>
<%
    WebApplicationContext context = WebApplicationContextUtils.getRequiredWebApplicationContext(application);
    Finances finances = context.getBean(Finances.class);

%>
<html>
<head>
    <title></title>
    <style type="text/css">
        ul {
            /*padding: 0;*/
            margin: 0;
        }
    </style>
</head>
<body>
<jsp:include page="top.jsp"/>
<%
    Item root = finances.loadRoot();
    try {
%>
<fin:items-tree item="<%= root %>"/><%
} catch (Exception ex) {
%><%=ex %><%
    }
%>
</body>
</html>
