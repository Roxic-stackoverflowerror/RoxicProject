package com.roxic.crm.workbench.dao;

import com.roxic.crm.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

public interface TranDao {

    int save(Tran tran);

    Integer getTotalByCondition(Map<String, Object> map);


    List<Tran> getTranListByCondition(Map<String, Object> map);

    Tran detail(String id);

    int changeStage(Tran tran);

    int getTotal();

    List<Map<String, Object>> getCharts();

    List<Tran> getTranListByCuid(String id);

    int remove(String id);

    List<Tran> getTranListByConid(String id);

    int delete(String[] ids);

    Tran getTranById(String id);

    int update(Tran tran);
}
