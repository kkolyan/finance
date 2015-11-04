<%@ tag import="com.nplekhanov.finance.Group" %>
<%@ tag language="java" %>
<%@ taglib prefix="fin" tagdir="/WEB-INF/tags" %>
<%@ attribute name="item" type="com.nplekhanov.finance.Item" required="true" %>
<li>

    <%=item.getName()%>
    <%
    if (item instanceof Group) {
        %><ul><%
        for (com.nplekhanov.finance.Item child: ((Group)item).getChildren()) {
            %> <fin:items-tree item="<%=child%>"/> <%
        }
        %></ul><%
    } else {
        %>  <a href="transfer.jsp?transferId=<%=item.getItemId()%>"><%=item%></a>  <%
    }
    %>
</li>