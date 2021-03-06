<%@ page language="java" %>
<%@ page contentType="text/html;charset=GBK"%>
<%@ page import="com.software.main.*,com.software.main.db.*"%>
<%@ page import="com.software.util.*,com.software.common.*"%>
<%@ page import="org.apache.commons.logging.*"%>
<%@ page import="java.io.*,java.util.*"%>
<%@page import="com.alibaba.fastjson.JSON" %>
<%!
private static Log log = LogFactory.getLog(Tool.class);
%>
<%
log.debug("ListJquery");
StringBuffer str = new StringBuffer();
String keyfield = (String)request.getAttribute("keyfield");
String[] dickeys = (String[])request.getAttribute("dickeys");
String[][] dicvalues = (String[][])request.getAttribute("dicvalues");
String[] fields = (String[])request.getAttribute("fields");
String OperateField = (String)request.getAttribute("OperateField");
List diclist = new ArrayList();
for (int i = 0; i < dickeys.length; i ++) {
    diclist.add("\"" + dickeys[i] + "\": [\"" + Tool.join("\", \"", dicvalues[i]) + "\"]");
}
int currpage = ParamUtils.getIntParameter(request, "page", 1);
Map extMaps = (Map)request.getAttribute("Ext");
List paras = HttpTool.getSavedUrlForm(request, "Ext");
List urls = (List)paras.get(0);
List forms = (List)paras.get(1);
urls.addAll((List)paras.get(2));
String url = Tool.join("&", urls);
PageControl pc = (PageControl)request.getAttribute("PageControl");
//默认值定义
List YesNooptions = (List)request.getAttribute("YesNooptions");
List TaskNameoptions = (List)request.getAttribute("TaskNameoptions");
List CarNameoptions = (List)request.getAttribute("CarNameoptions");
%>
<html>
<head>
<title> <%=request.getAttribute("describe")%> </title>
<jsp:include page="/jqueryinc.jsp">
<jsp:param value="metro-blue" name="style"/>
</jsp:include>
<script type="text/javascript">
var keyfield = "<%=keyfield%>";
var OperateField = "<%=OperateField%>";
var datagrid;
var editRow = undefined;
$(function () {
    $("#dlg").dialog("close");
    initData();
});
 function initData(){
    datagrid = $("#dadagrid").datagrid({
            url: 'CarSchedulingAction.jsp?cmd=json',
            iconCls: 'icon-save',
            pagination: true,
        	 rownumbers: true,
            pageSize: <%=pc.getShownum()%>,
            pageList: [<%=pc.getShownum()%>, <%=pc.getShownum()*2%>, <%=pc.getShownum()*3%>, <%=pc.getShownum()*4%>],
            fit: true,
            fitColumn: false,
            striped: true,
            nowap: true, 
            border: false,
            idField: keyfield,
            columns: [[ 
        <%
        List rows = new ArrayList();
        for(int i=0;i<fields.length;i++){
            	int listFieldIndex = 0;
            	for(int j=0;j<dickeys.length;j++)
            	{
                		if(dickeys[j]==fields[i])
                		{
                    			listFieldIndex = j;
                    			break;
                		}
            	}
            	Map map = new HashMap();
            	map.put("field",dickeys[listFieldIndex]+"");
            	map.put("title",dicvalues[listFieldIndex][1]+"");
            	map.put("sortable","true");
            	map.put("halign","center");
            	if(dickeys[listFieldIndex].equals(keyfield))
            	{
                		map.put("checkbox","true");
            	}
            	rows.add(JSON.toJSONString(map));
        }
        out.print(Tool.join(",\r\n",rows));%>
        ,{
            title:"操作",
            field:"<%=OperateField%>",
            halign:"center",
            align:"center",
            formatter : function(value, rowData, rowIndex) {
                	var keyid = eval("rowData."+keyfield);
                	return '<input type="button"  value="修改" onclick="modifyFun(\''+ keyid +'\')"></button>';
             		  },
            width:80
        }
        ]],
        queryParams : sy.serializeObject($("#CarScheduling_queryForm").form()),
        	toolbar : '#toolbar',
        	onDblClickRow :onClickRow
    })
}
//$('.datagrid-header div').css("textAlign","center");
 function reloadData(){
    	$("#dadagrid").datagrid("load");
}
//查询
function searchFun()
{
    	$("#dadagrid").datagrid("load",sy.serializeObject($("#CarScheduling_queryForm").form()));
}
//点击清空按钮出发事件
function clearSearch() {
    	$("#dadagrid").datagrid("load", {});//重新加载数据，无填写数据，向后台传递值则为空
    	$("#CarScheduling_queryForm").find("input").val("");//找到form表单下的所有input标签并清空
}
//添加
function addFun() {
    	$("#openDlgIframe")[0].src="<%=request.getAttribute("classname")%>Action.jsp?cmd=jqueryCreate";
    	$("#openDlgDiv").dialog("open");
}
//修改
function modifyFun(id) {
    	$("#openDlgIframe")[0].src="<%=request.getAttribute("classname")%>Action.jsp?cmd=jqueryModify&"+keyfield+"="+id;
    	$("#openDlgDiv").dialog("open");
}
//删除
function delFun() {
    	var rows = $("#dadagrid").datagrid("getChecked");
    	var ids = [];
    	if (rows.length > 0 ) {
        		$.messager.confirm("确认", "您是否要删除当前选中的记录？", function(r) {
            		if (r) {
                			$.messager.progress({
                    			title : "提示",
                    			text : "数据处理中，请稍后...."
                	});
                	for ( var i = 0; i < rows.length; i++) {
                    			ids.push(rows[i].Id);
                	}
                	$.getJSON("<%=request.getAttribute("classname")%>Action.jsp?cmd=jqueryDeletelist", {
                    		idlist : ids.join(",")
                    	}, function(result) {
                    		if (result.success) {
                        			reloadData();
                    		}
                    		if(result.msg && result.msg.length>0)
                    			{
                        				$.messager.alert("提示", result.msg, "info");
                    			}
                    			$.messager.progress("close");
                		});
            	}
        	});
    	}else
    	{
        		$.messager.alert("提示", "请选择记录后再进行删除操作", "info");
    	}
}
</script>
</head>
<body class="easyui-layout">
<div data-options="region:'center',split:true" title="" style="">
<table id="dadagrid">
</table>
<div id="toolbar" style="display: none;">
<a href="#" class="easyui-linkbutton" data-options="iconCls:'icon-add'" style="width:80px" onClick="addFun();">添加</a>
<a href="#" class="easyui-linkbutton" data-options="iconCls:'icon-no'" style="width:80px" onClick="delFun();">删除</a>
</div>
<div id="menu" class="easyui-menu" style="width:120px;display:none;">
<div onClick="" iconCls="icon-add">增加</div>
<div onClick="" iconCls="icon-remove">删除</div>
<div onClick="" iconCls="icon-edit">修改</div>
</div>
<div id="dlg" class="easyui-dialog" title="添加/修改" data-options="iconCls:'icon-save'" style="width:800px;height:500px;padding:10px">
</div>
<div id="openDlgDiv" class="easyui-window" closed="true" modal="true" title="添加/修改" style="width:800px;height:550px;overflow:hidden">
	<iframe scrolling="auto" id="openDlgIframe" frameborder="0"  src="" style="width:100%;height:99%;"></iframe>
</div>
</div>
<div data-options="region:'north',split:true" title="查询" style="height: 110px; overflow: auto;">
<form id="CarScheduling_queryForm" name="CarScheduling_queryForm" method="post">
<table border="0" width="100%" cellspacing="0" id="searchTable" class="tableForm datagrid-toolbar">
<input type="hidden" name="cmd" id="cmd" value="listjquery">
<%=Tool.join("\n", forms)%>
<td>
<div align="right">小车</div>
</td><td>
<%=HtmlTool.renderSelect(CarNameoptions, ParamUtils.getParameter(request,"_Carid_",""), "_Carid_", "")%>
<%//radio形式%>
<%//CarNameoptions.remove(0);%>
<%//=HtmlTool.renderRadio(CarNameoptions, ParamUtils.getParameter(request,"_Carid_",""), "_Carid_", "")%>
<%//checkbox形式%>
<%//=HtmlTool.renderCheckBox(CarNameoptions, ParamUtils.getParameter(request,"_Carid_",""), "_Carid_", "")%>
</td>
<td>
<div align="right">任务ID</div>
</td><td>
<%=HtmlTool.renderSelect(TaskNameoptions, ParamUtils.getParameter(request,"_Taskid_",""), "_Taskid_", "")%>
<%//radio形式%>
<%//TaskNameoptions.remove(0);%>
<%//=HtmlTool.renderRadio(TaskNameoptions, ParamUtils.getParameter(request,"_Taskid_",""), "_Taskid_", "")%>
<%//checkbox形式%>
<%//=HtmlTool.renderCheckBox(TaskNameoptions, ParamUtils.getParameter(request,"_Taskid_",""), "_Taskid_", "")%>
</td>
<td>
<div align="right">运行速度</div>
</td><td>
<input name="_Dqsd_" id="_Dqsd_"value="<%=ParamUtils.getParameter(request, "_Dqsd_", "")%>">
</td>
</tr><tr>
<td>
<div align="right">电池电压</div>
</td><td>
<input name="_Dqdy_" id="_Dqdy_"value="<%=ParamUtils.getParameter(request, "_Dqdy_", "")%>">
</td>
<td>
<div align="right">负载状态</div>
</td><td>
<%=HtmlTool.renderSelect(YesNooptions, ParamUtils.getParameter(request,"_Fzzt_",""), "_Fzzt_", "")%>
<%//radio形式%>
<%//YesNooptions.remove(0);%>
<%//=HtmlTool.renderRadio(YesNooptions, ParamUtils.getParameter(request,"_Fzzt_",""), "_Fzzt_", "")%>
<%//checkbox形式%>
<%//=HtmlTool.renderCheckBox(YesNooptions, ParamUtils.getParameter(request,"_Fzzt_",""), "_Fzzt_", "")%>
</td>
<td>
<div align="right">运行状态</div>
</td><td>
<%=HtmlTool.renderSelect(YesNooptions, ParamUtils.getParameter(request,"_Yxzt_",""), "_Yxzt_", "")%>
<%//radio形式%>
<%//YesNooptions.remove(0);%>
<%//=HtmlTool.renderRadio(YesNooptions, ParamUtils.getParameter(request,"_Yxzt_",""), "_Yxzt_", "")%>
<%//checkbox形式%>
<%//=HtmlTool.renderCheckBox(YesNooptions, ParamUtils.getParameter(request,"_Yxzt_",""), "_Yxzt_", "")%>
</td>
</tr><tr>
<td>
<div align="right">起点</div>
</td><td>
<input name="_Qd_" id="_Qd_"value="<%=ParamUtils.getParameter(request, "_Qd_", "")%>">
</td>
<td>
<div align="right">终点</div>
</td><td>
<input name="_Zd_" id="_Zd_"value="<%=ParamUtils.getParameter(request, "_Zd_", "")%>">
</td>
<td>
<div align="right">运行时间</div>
</td><td>
<input name="_Yxtime_" id="_Yxtime_"value="<%=ParamUtils.getParameter(request, "_Yxtime_", "")%>">
</td>
</tr><tr>
<input type="hidden" name="_TaskRemark_" id="_TaskRemark_" value="<%=ParamUtils.getParameter(request, "_TaskRemark_", "")%>">
</tr><tr><td colspan="8" align="center">
<a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-search'" style="width:80px" onclick="searchFun()">查询</a>
<a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-reload'" style="width:80px"  onclick="clearSearch()">清空</a>
</td></tr></table>
	</form>
</div>
</body>
</html>
