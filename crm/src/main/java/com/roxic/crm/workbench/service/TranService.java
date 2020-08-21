package com.roxic.crm.workbench.service;

import com.roxic.crm.vo.PageListVO;
import com.roxic.crm.workbench.domain.Contacts;
import com.roxic.crm.workbench.domain.Tran;
import com.roxic.crm.workbench.domain.TranHistory;

import java.util.List;
import java.util.Map;

public interface TranService {


    PageListVO<Tran> pageList(Map<String, Object> map);

    boolean save(Tran tran, String customerName);

    Tran detail(String id);

    List<TranHistory> getHistoryListByTranId(String tranId);

    boolean changeStage(Tran tran);

    Map<String, Object> getCharts();

    boolean remove(String id);

    boolean delete(String[] ids);

    Tran getTranById(String id);

    boolean update(Tran tran);
}
