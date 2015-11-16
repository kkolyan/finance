<%@ tag import="com.nplekhanov.finance.*" %>
<%@ tag import="java.util.*" %>
<%@ tag language="java" %>
<%@ taglib prefix="fin" tagdir="/WEB-INF/tags" %>
<%@ attribute name="item" type="com.nplekhanov.finance.Item" required="true" %>

<%
    if (item instanceof Group) {
        %><ul><%
    List<Item> children = new ArrayList<>(((Group) item).getChildren());
    Collections.sort(children, new ItemComparator());
    for (com.nplekhanov.finance.Item child: children) {
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