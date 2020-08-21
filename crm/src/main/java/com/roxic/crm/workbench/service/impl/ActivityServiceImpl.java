package com.roxic.crm.workbench.service.impl;

import com.roxic.crm.settings.dao.UserDao;
import com.roxic.crm.settings.domain.User;
import com.roxic.crm.utils.SqlSessionUtil;
import com.roxic.crm.vo.PageListVO;
import com.roxic.crm.workbench.dao.ActivityDao;
import com.roxic.crm.workbench.dao.ActivityRemarkDao;
import com.roxic.crm.workbench.domain.Activity;
import com.roxic.crm.workbench.domain.ActivityRemark;
import com.roxic.crm.workbench.service.ActivityService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ActivityServiceImpl implements ActivityService {

    private ActivityDao activityDao = SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);
    private ActivityRemarkDao activityRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ActivityRemarkDao.class);
    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);

    @Override
    public boolean save(Activity activity) {
        boolean flag = true;

        int count = activityDao.save(activity);

        if(count != 1){
            flag = false;
        }
        return flag;
    }

    @Override
    public PageListVO<Activity> pageList(Map<String, Object> map) {
        //取总条数
        Integer total = activityDao.getTotalByCondition(map);

        //取得dataList
        List<Activity> dataList = activityDao.getActivityListByCondition(map);

        //创建vo，打包
        PageListVO<Activity> vo = new PageListVO<Activity> ();
        vo.setTotal(total);
        vo.setDataList(dataList);

        //返回
        return vo;
    }

    @Override
    public boolean delete(String[] ids) {

        boolean flag = true;

        //查询出需要删除的备注的数量
        int count1 = activityRemarkDao.getCountsByAids(ids);
        //删除备注，返回受影响的条数
        int count2 = activityRemarkDao.deleteByAids(ids);

        if(count1 != count2){
            flag = false;
        }
        //删除市场活动
        int count3 = activityDao.delete(ids);
        if(count3 != ids.length){
            flag = false;
        }
        return flag;
    }

    @Override
    public Map<String, Object> getUserListAndActivity(String id) {
        List<User> uList = userDao.getUserList();
        Activity activity = activityDao.getActivityById(id);
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("uList",uList);
        map.put("activity",activity);
        return map;
    }

    @Override
    public boolean update(Activity activity) {
        boolean flag = true;

        int count = activityDao.update(activity);

        if(count != 1){
            flag = false;
        }
        return flag;
    }

    @Override
    public Activity detail(String id) {
        Activity activity = activityDao.detail(id);
        return activity;
    }

    @Override
    public List<ActivityRemark> getRemarkListByAid(String activityId) {
        List<ActivityRemark> arList = activityRemarkDao.getRemarkListByAid(activityId);
        return arList;
    }

    @Override
    public boolean removeRemark(String id) {
        boolean flag = true;

        int count = activityRemarkDao.removeRemark(id);

        if(count != 1){
            flag = false;
        }
        return flag;
    }

    @Override
    public boolean saveRemark(ActivityRemark ar) {
        boolean flag = true;
        int count = activityRemarkDao.saveRemark(ar);
        if(count != 1){
            flag = false;
        }
        return flag;
    }

    @Override
    public boolean updateRemark(ActivityRemark ar) {
        boolean flag = true;
        int count = activityRemarkDao.updateRemark(ar);
        if(count != 1){
            flag = false;
        }
        return flag;
    }

    @Override
    public List<Activity> getActivityListByClueId(String clueId) {
        List<Activity> activityList = activityDao.getActivityListByClueId(clueId);
        return activityList;
    }

    @Override
    public List<Activity> getActivityListByNameAndNotByClueId(Map<String, String> map) {
        List<Activity> activityList = activityDao.getActivityListByNameAndNotByClueId(map);
        return activityList;
    }

    @Override
    public List<Activity> getActivityListByName(String activityName) {
        List<Activity> activityList = activityDao.getActivityListByName(activityName);
        return activityList;
    }

    @Override
    public List<Activity> getActivityListByContactsId(String contactsId) {
        List<Activity> activityList = activityDao.getActivityListByContactsId(contactsId);
        return activityList;
    }

    @Override
    public List<Activity> getActivityListByNameAndNotByContactsId(Map<String, String> map) {
        List<Activity> activityList = activityDao.getActivityListByNameAndNotByContactsId(map);
        return activityList;
    }
}
