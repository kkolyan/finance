<%@ tag import="com.nplekhanov.finance.*" %>
<%@ tag import="java.util.*" %>
<%@ tag language="java" %>
<%@ taglib prefix="fin" tagdir="/WEB-INF/tags" %>
<%@ attribute name="item" type="com.nplekhanov.finance.Item" required="true" %>

    <%
    if (item instanceof Group) {
        %><ul><%
    List<Item> children = new ArrayList<>(((Group) item).getChildren());
    Collections.sort(children, new Comparator<Item>() {
        @Override
        public int compare(Item o1, Item o2) {
            if (o1 instanceof InstantTransfer) {
                if (o2 instanceof InstantTransfer) {
                    return ((InstantTransfer) o1).getAt().compareTo(((InstantTransfer) o2).getAt());
                }
                if (o2 instanceof MonthlyPlannedTransfer) {
                    return -1;
                }
                if (o2 instanceof Group) {
                    return -1;
                }
                throw new IllegalStateException();
            }
            if (o1 instanceof MonthlyPlannedTransfer) {
                if (o2 instanceof MonthlyPlannedTransfer) {
                    return ((MonthlyPlannedTransfer) o1).getBegin().compareTo(((MonthlyPlannedTransfer) o2).getBegin());
                }
                if (o2 instanceof Group) {
                    return -1;
                }
            }
            if (o1 instanceof Group) {
                if (o2 instanceof Group) {
                    return o1.getName().compareTo(o2.getName());
                }
            }
            return -compare(o2, o1);
        }
    });
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