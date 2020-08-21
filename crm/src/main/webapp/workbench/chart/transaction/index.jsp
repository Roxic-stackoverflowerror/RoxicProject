<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
    /*
     * 需求：
     *       根据交易表中的不同的阶段的数量进行统计，最终形成个漏斗图
     *
     *       将统计出来阶段数量比较多的，往上排列
     *       将统计出来的阶段的数量比较少的，往下排列
     *
     *       sql：
     *       select
     *
     *       stage,count(*) as amount
     *
     *       from tble_tran
     *
     *       group by stage
     * */
%>
<html>
<head>
    <base href="<%=basePath%>">
    <script src="ECharts/echarts.min.js"></script>
    <script src="jquery/jquery-1.11.1-min.js"></script>

    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
            background-color: #EAEAEA;
        }

        .center-in-center {
            position: absolute;
            top: 50%;
            left: 50%;
            -webkit-transform: translate(-50%, -50%);
            -moz-transform: translate(-50%, -50%);
            -ms-transform: translate(-50%, -50%);
            -o-transform: translate(-50%, -50%);
            transform: translate(-50%, -50%);
        }
    </style>

    <script type="text/javascript">

        $(function () {
            //在页面加载完毕后，绘制统计图表
            getCharts();
        });//load事件末尾

        function getCharts() {
            //alert(11);

            $.ajax({
                url:"workbench/transaction/getCharts.do",
                type:"get",
                dataType:"json",
                success: function (data) {
                    var myChart = echarts.init(document.getElementById('main'));
                    option = {
                        title: {
                            text: '交易漏斗图',
                            subtext: '统计交易阶段数量'
                        },
                        tooltip: {
                            trigger: 'item',
                        },
                        toolbox: {
                            feature: {
                                dataView: {readOnly: true},
                                saveAsImage: {}
                            }
                        },

                        series: [
                            {
                                name: '交易漏斗图',
                                type: 'funnel',
                                left: '10%',
                                top: 60,
                                //x2: 80,
                                bottom: 60,
                                width: '80%',
                                // height: {totalHeight} - y - y2,
                                min: 0,
                                max: data.total,
                                minSize: '0%',
                                maxSize: '100%',
                                sort: 'descending',
                                gap: 2,
                                label: {
                                    show: true,
                                    position: 'inside'
                                },
                                labelLine: {
                                    length: 10,
                                    lineStyle: {
                                        width: 1,
                                        type: 'solid'
                                    }
                                },
                                itemStyle: {
                                    borderColor: '#fff',
                                    borderWidth: 1
                                },
                                emphasis: {
                                    label: {
                                        fontSize: 20
                                    }
                                },
                                data: data.dataList/*[
                                                       {value: 60, name: '访问'},
                                                       {value: 40, name: '咨询'},
                                                       {value: 20, name: '订单'},
                                                       {value: 80, name: '点击'},
                                                       {value: 100, name: '展现'}
                                                      ]*/
                            }
                        ]
                    };

                    // 使用刚指定的配置项和数据显示图表。
                    myChart.setOption(option);
                }
            })

        }


    </script>
</head>
<body>
<!-- 为 ECharts 准备一个具备大小（宽高）的 DOM -->
<div id="main" style="width: 1200px;height:800px;" class="center-in-center"></div>
</body>
</html>
