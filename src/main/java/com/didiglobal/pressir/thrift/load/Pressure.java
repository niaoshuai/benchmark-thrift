package com.didiglobal.pressir.thrift.load;

import com.didiglobal.pressir.thrift.constant.Constants;

/**
 * @ClassName Pressure
 * @Description 压力曲线
 * @Author pressir
 * @Date 2019-08-30 16:34
 */
public class Pressure {

    private int quantity;

    private int duration;

    private long beginTime;

    public Pressure(int quantity, String duration) {
        this(quantity, duration, System.currentTimeMillis() / Constants.TIME_CONVERT_BASE + 1);
    }

    private Pressure(int quantity, String duration, long beginTime) {
        if (quantity <= 0) {
            throw new IllegalArgumentException("the pressure should be greater than 0");
        }
        this.quantity = quantity;
        this.duration = DurationParser.parse(duration);
        if (this.duration <= 0) {
            throw new IllegalArgumentException("the duration should be greater than 0");
        }
        this.beginTime = beginTime;
    }

    public int getCurrentQuantity() {
        if (System.currentTimeMillis() / Constants.TIME_CONVERT_BASE - this.beginTime >= this.duration) {
            return -1;
        }
        return this.quantity;
    }

}
