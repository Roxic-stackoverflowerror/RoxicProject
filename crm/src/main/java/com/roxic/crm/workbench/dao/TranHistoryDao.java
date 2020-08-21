package com.roxic.crm.workbench.dao;

import com.roxic.crm.workbench.domain.TranHistory;

import java.util.List;

public interface TranHistoryDao {

    int save(TranHistory tranHistory);

    List<TranHistory> getHistoryListByTranId(String tranId);

    int getCountsByTids(String[] ids);

    int deleteByTids(String[] ids);
}
