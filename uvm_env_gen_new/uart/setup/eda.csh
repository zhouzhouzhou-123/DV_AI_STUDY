

# -------- vcs -------- #
# module switch vcs/Q-2020.03-SP2

# -------- verdi ----------- #
# module switch verdi/Q-2020.03-SP2

# -------- xa -------- #
# module switch xa/Q-2020.03-SP4

# -------- vmanager -------- #
# module switch incisive/15.20

setenv VCS_HOME             /eda/synopsys/vcs/X-2025.06-SP2
setenv UVM_HOME             $VCS_HOME/etc/uvm
setenv COMMON_VIP_PATH      /home/zhouxk/project/dig_veri_ip/cs-digital-ip/common_vip
setenv SVT_VIP_PATH         /vendor/SYNOPSYS/2019.06/vip/svt

# used for regression(vManager)
setenv XXX_VERI_PATH        /simulation/cs8m330/$user/cs8m330aa/trunk/Code/digital/Veri/S_veri
