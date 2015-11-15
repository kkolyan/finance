<%@ tag import="com.nplekhanov.finance.Group" %>
<%@ tag import="com.nplekhanov.finance.InstantTransfer" %>
<%@ tag import="com.nplekhanov.finance.Formats" %>
<%@ tag import="com.nplekhanov.finance.MonthlyPlannedTransfer" %>
<%@ tag language="java" %>
<%@ taglib prefix="fin" tagdir="/WEB-INF/tags" %>
<%@ attribute name="item" type="com.nplekhanov.finance.Item" required="true" %>

    <%
    if (item instanceof Group) {
        %><ul><%
        for (com.nplekhanov.finance.Item child: ((Group)item).getChildren()) {
            %><li><%
            %><a href="transfer.jsp?transferId=<%=child.getItemId()%>"><%=child.getName()%>
            <%
            %>
            </a><%
            if (child instanceof InstantTransfer) {
                %> <%=((InstantTransfer) child).getAt().format(Formats.DATE_TIME)%>, <%=((InstantTransfer) child).getAmount()%><%
            }
            if (child instanceof MonthlyPlannedTransfer) {
                %> <%=((MonthlyPlannedTransfer) child).getBegin().format(Formats.YEAR_MONTH)%>..<%=((MonthlyPlannedTransfer) child).getEnd().format(Formats.YEAR_MONTH)%>, <%=((MonthlyPlannedTransfer) child).getAmount()%><%
            }
            %> <fin:items-tree item="<%=child%>"/> <%
            %></li><%
        }
        %></ul><%
    }
    %>