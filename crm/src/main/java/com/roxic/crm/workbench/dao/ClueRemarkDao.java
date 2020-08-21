package com.roxic.crm.workbench.dao;

import com.roxic.crm.workbench.domain.ActivityRemark;
import com.roxic.crm.workbench.domain.ClueRemark;

import java.util.List;

public interface ClueRemarkDao {

    int getCountsByCids(String[] ids);

    int deleteByCids(String[] ids);

    List<ClueRemark> getListByClueId(String clueId);

    int delete(ClueRemark clueRemark);

    int saveRemark(ClueRemark cr);

    int updateRemark(ClueRemark cr);

    int removeRemark(String id);

    List<ClueRemark> getRemarkListByCid(String clueId);
}
