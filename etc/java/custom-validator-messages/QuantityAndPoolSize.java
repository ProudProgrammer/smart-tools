package org.gaborbalazs.smartplatform.lotteryservice.web.domain;

import javax.validation.constraints.Min;

public final class Test {

    @Min(value = 2, message = "{validate.test}")
    private final int test;

    public Test(int test) {
        this.quantity = quantity;
    }

    public int getTest() {
        return test;
    }
}
