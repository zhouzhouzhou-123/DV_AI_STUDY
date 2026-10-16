
//System initial function

//Main function
int main (void) {
    uint32_t data;

    print_ok(100);
    print_error(200);
    ccode_send_label(100);

    ccode_send_data(0, 0x22);
    ccode_send_data(18, 0x28);
    ccode_send_label(101);

    ccode_wait_label(102);
    data = ccode_get_data(1);
    print_ok(data);
    data = ccode_get_data(19);
    print_ok(data);

    core_sim_end();
}


