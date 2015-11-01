<%@ tag import="com.nplekhanov.finance.Item" %>
<%@ tag import="com.nplekhanov.finance.Transfer" %>
<%@ tag language="java" %>
<%@ taglib prefix="fin" tagdir="/WEB-INF/tags" %>
<%@ attribute name="item" type="com.nplekhanov.finance.Item" required="true" %>
<li>

    <%=item.getName()%>
    <%
    if (!item.getChildren().isEmpty()) {
        %><ul><%
        for (Item child: item.getChildren()) {
            %> <fin:items-tree item="<%=child%>"/> <%
        }
        %></ul><%
    }
    if (!item.getTransfers().isEmpty()) {
        %><ul><%
        for (Transfer transfer: item.getTransfers()) {
            %>  <a href="transfer.jsp?transferId=<%=transfer.getTransferId()%>"><%=transfer%></a>  <%
        }
        %></ul><%
    }
    %>
</li>