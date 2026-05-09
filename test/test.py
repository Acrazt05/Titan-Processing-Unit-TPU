import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_uo_out_equals_ui_plus_one(dut):

    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # -------------------------
    # RESET
    # -------------------------
    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1

    # -------------------------
    # TEST VECTOR 1
    # -------------------------
    test_val = 20
    dut.ui_in.value = test_val

    await ClockCycles(dut.clk, 50000)

    expected = (test_val + 1) & 0xFF
    actual = dut.uo_out.value.integer & 0xFF

    dut._log.info(f"ui_in={test_val}, uo_out={actual}, expected={expected}")

    assert actual == expected, f"Mismatch: got {actual}, expected {expected}"