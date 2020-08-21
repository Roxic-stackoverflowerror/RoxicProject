package com.roxic.crm.web.listener;

import com.roxic.crm.settings.domain.DicValue;
import com.roxic.crm.settings.service.DicService;
import com.roxic.crm.settings.service.Impl.DicServiceImpl;
import com.roxic.crm.utils.ServiceFactory;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.util.*;

public class SysInitListener implements ServletContextListener {
    public void contextInitialized(ServletContextEvent event ){

        /*
        * 该方法用来监听上下文域对象的方法，当服务器启动，上下域对象创建
        * 对象创建完毕后，马上执行该方法
        *
        * event能够取得监听对象，监听的是什么对象，就能取得什么对象
        * */
        System.out.println("服务器处理数据字典缓存开始");

        ServletContext application = event.getServletContext();
        //取数据字典
        DicService dicService = (DicService) ServiceFactory.getService(new DicServiceImpl());

        /*
        * 向业务层要7个List，可以打包成一个Map
        * 业务层：
        *       map.put("appellationList",dicServiceList1);
        *       map.put("clueStateList",dicServiceList2);
        *       map.put("stageList",dicServiceList3);
        *       ...
        * */

        Map<String, List<DicValue>> map = dicService.getAll();

        //拆解map，解析为上下域对象中保存的键值对
        Set<String> set = map.keySet();
        for(String key : set){

            application.setAttribute(key,map.get(key));

        }
        System.out.println("服务器处理数据字典缓存结束");

        //--------------------------------------------------------

        /*

            处理Stage2Possibility.properties文件步骤：
                解析该文件，将该属性文件中的键值对关系处理成为java中键值对关系（map）

                Map<String(阶段stage),String(可能性possibility)> possibilityMap = ....
                possibilityMap.put("01资质审查",10);
                possibilityMap.put("02需求分析",25);
                possibilityMap.put("07...",...);

                possibilityMap保存值之后，放在服务器缓存中
                application.setAttribute("possibilityMap",possibilityMap);

         */

        //解析properties文件

        Map<String,String>  possibilityMap = new HashMap<String,String>();

        ResourceBundle resourceBundle = ResourceBundle.getBundle("Stage2Possibility");

        Enumeration<String> enumeration = resourceBundle.getKeys();

        while (enumeration.hasMoreElements()){

            //阶段
            String key = enumeration.nextElement();
            //可能性
            String value = resourceBundle.getString(key);

            possibilityMap.put(key, value);


        }

        //将possibilityMap保存到服务器缓存中
        application.setAttribute("possibilityMap", possibilityMap);

    }
}
