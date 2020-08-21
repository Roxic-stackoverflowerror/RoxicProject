package com.roxic.crm.workbench.service;

import com.roxic.crm.vo.PageListVO;
import com.roxic.crm.workbench.domain.ActivityRemark;
import com.roxic.crm.workbench.domain.Clue;
import com.roxic.crm.workbench.domain.ClueRemark;
import com.roxic.crm.workbench.domain.Tran;

import javax.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.Map;

public interface ClueService {
    boolean save(Clue clue);

    PageListVO<Clue> pageList(Map<String, Object> map);

    boolean delete(String[] ids);

    Clue detail(String id);

    boolean unbound(String id);

    boolean bound(String clueId, String[] activityIds);

    boolean convert(String clueId, Tran tran, String createBy);

    Map<String, Object> getUserListAndClue(String id);

    boolean update(Clue clue);

    boolean saveRemark(ClueRemark cr);

    boolean updateRemark(ClueRemark cr);

    boolean removeRemark(String id);

    List<ClueRemark> getRemarkListByCid(String clueId);
}
