import re
from array import *
import fileinput
import sys, getopt
import csv

def main(argv):
    NumberOfRows = 16;
    NumberOfCols = 19;
    FrameBitsPerRow = 32;
    MaxFramesPerCol = 20;
    desync_flag = 20;
    FrameSelectWidth = 5;
    RowSelectWidth = 5;
    NumberOfBRAMs = 4;

    #shared_lut_list = []
    print("hello\n")
    
    try:
        opts, args = getopt.getopt(argv,"hr:c:b:f:d:m:",["NumberOfRows=","NumberOfCols=","FrameBitsPerRow=","MaxFramesPerCol=","desync_flag=","block_ram="])
    except getopt.GetoptError:
        print ('top_wrapper_generator.py -r <NumberOfRows> -c <NumberOfCols> -b <FrameBitsPerRow> -f <MaxFramesPerCol> -d <desync_flag> -m <block_ram>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print ('top_wrapper_generator.py -r <NumberOfRows> -c <NumberOfCols> -b <FrameBitsPerRow> -f <MaxFramesPerCol> -d <desync_flag> -m <block_ram>')
            sys.exit()
        elif opt in ("-r", "--NumberOfRows"):
            NumberOfRows = int(arg)
        elif opt in ("-c", "--NumberOfCols"):
            NumberOfCols = int(arg)+2
        elif opt in ("-b", "--FrameBitsPerRow"):
            FrameBitsPerRow = int(arg)
        elif opt in ("-f", "--MaxFramesPerCol"):
            MaxFramesPerCol = int(arg)
        elif opt in ("-d", "--desync_flag"):
            desync_flag = int(arg)
        elif opt in ("-m", "--block_ram"):
            NumberOfBRAMs = int(arg)

    NumberOfBRAMs = int(NumberOfRows/2);

    print ('NumberOfRows     :', NumberOfRows)
    print ('NumberOfCols     :', NumberOfCols-2)
    print ('FrameBitsPerRow  :', FrameBitsPerRow)
    print ('MaxFramesPerCol  :', MaxFramesPerCol)
    print ('desync_flag      :', desync_flag)
    print ('FrameSelectWidth :', FrameSelectWidth)
    print ('RowSelectWidth   :', RowSelectWidth)
    print ('NumberOfBRAMs   :', NumberOfBRAMs)
    print ('')

    wrapper_top_str = ""
    config_str = ""
    configfsm_str = ""
    data_reg_modules = ""
    strobe_reg_modules = ""
    testbench_str = ""
    #data_reg_module_temp = ""
    
    
    try:
        with open("fabulous_top_wrapper_temp/eFPGA_v3_top_sky130_with_BRAM_template.v", 'r') as file :
            wrapper_top_str = file.read()
    except IOError:
        print("eFPGA_v3_top_sky130_with_BRAM_template.v not accessible")
        
    try:
        with open("fabulous_top_wrapper_temp/Config_template.v", 'r') as file :
            config_str = file.read()
    except IOError:
        print("Config_template.v not accessible")
        
    try:
        with open("fabulous_top_wrapper_temp/ConfigFSM_template.v", 'r') as file :
            configfsm_str = file.read()
    except IOError:
        print("ConfigFSM_template.v not accessible")
        
    try:
        with open("fabulous_top_wrapper_temp/tb_bitbang_template.vhd", 'r') as file :
            testbench_str = file.read()
    except IOError:
        print("tb_bitbang_template.vhd not accessible")
    
    wrapper_top_str = wrapper_top_str.replace("[30:0] io_in", '['+str(NumberOfRows*4+7)+'-1:0] io_in')
    wrapper_top_str = wrapper_top_str.replace("[30:0] io_out", '['+str(NumberOfRows*4+7)+'-1:0] io_out')
    wrapper_top_str = wrapper_top_str.replace("[30:0] io_oeb", '['+str(NumberOfRows*4+7)+'-1:0] io_oeb')

    wrapper_top_str = wrapper_top_str.replace("[32-1:0] I_top", '['+str(NumberOfRows*4)+'-1:0] I_top')
    wrapper_top_str = wrapper_top_str.replace("[32-1:0] T_top", '['+str(NumberOfRows*4)+'-1:0] T_top')
    wrapper_top_str = wrapper_top_str.replace("[32-1:0] O_top", '['+str(NumberOfRows*4)+'-1:0] O_top')
    wrapper_top_str = wrapper_top_str.replace("[64-1:0] A_config_C", '['+str(NumberOfRows*4)+'-1:0] A_config_C')
    wrapper_top_str = wrapper_top_str.replace("[64-1:0] B_config_C", '['+str(NumberOfRows*4)+'-1:0] B_config_C')
    
    wrapper_top_str = wrapper_top_str.replace("localparam NumberOfRows = 16", "localparam NumberOfRows = "+str(NumberOfRows))
    wrapper_top_str = wrapper_top_str.replace("localparam NumberOfCols = 19", "localparam NumberOfCols = "+str(NumberOfCols))
    
    wrapper_top_str = wrapper_top_str.replace("O_top[23:18] = io_in[30:25]", "O_top["+str(NumberOfRows*4-1)+":18] = io_in["+str(NumberOfRows*4+7-1)+":25]")
    wrapper_top_str = wrapper_top_str.replace("io_out[30:7] = I_top", "io_out["+str(NumberOfRows*4+7-1)+":7] = I_top")
    wrapper_top_str = wrapper_top_str.replace("io_oeb[30:7] = T_top", "io_oeb["+str(NumberOfRows*4+7-1)+":7] = T_top")

    
    #config_str = config_str.replace("parameter NumberOfRows = 16", "parameter NumberOfRows = "+str(NumberOfRows))
    config_str = config_str.replace("parameter RowSelectWidth = 5", "parameter RowSelectWidth = "+str(RowSelectWidth))
    config_str = config_str.replace("parameter FrameBitsPerRow = 32", "parameter FrameBitsPerRow = "+str(FrameBitsPerRow))
    #config_str = config_str.replace("parameter desync_flag = 20", "parameter desync_flag = "+str(desync_flag))
    
    configfsm_str = configfsm_str.replace("parameter NumberOfRows = 16", "parameter NumberOfRows = "+str(NumberOfRows))
    configfsm_str = configfsm_str.replace("parameter RowSelectWidth = 5", "parameter RowSelectWidth = "+str(RowSelectWidth))
    configfsm_str = configfsm_str.replace("parameter FrameBitsPerRow = 32", "parameter FrameBitsPerRow = "+str(FrameBitsPerRow))
    configfsm_str = configfsm_str.replace("parameter desync_flag = 20", "parameter desync_flag = "+str(desync_flag))
    
    testbench_str = testbench_str.replace(" STD_LOGIC_VECTOR (32 -1 downto 0)", " STD_LOGIC_VECTOR ("+str(NumberOfRows*2)+" -1 downto 0)")
    testbench_str = testbench_str.replace("STD_LOGIC_VECTOR (64 -1 downto 0)", "STD_LOGIC_VECTOR ("+str(NumberOfRows*4)+" -1 downto 0)")
    
    
    # I_top_buf_str = ""
    # T_top_buf_str = ""
    # O_top_buf_str = ""
    # for i in range(NumberOfRows*2):
        # I_top_buf_str += "\tsky130_fd_sc_hd__buf_2 I_top_outbuf_"+str(i)+" (.A(I_top_buf["+str(i)+"]), .X(I_top["+str(i)+"]));\n"
        # T_top_buf_str += "\tsky130_fd_sc_hd__buf_2 T_top_outbuf_"+str(i)+" (.A(T_top_buf["+str(i)+"]), .X(T_top["+str(i)+"]));\n"
        # O_top_buf_str += "\tsky130_fd_sc_hd__buf_2 O_top_inbuf_"+str(i)+" (.A(O_top["+str(i)+"]), .X(O_top_buf["+str(i)+"]));\n"
        
    # A_config_C_buf_str = ""
    # B_config_C_buf_str = ""
    # for j in range(NumberOfRows*4):
        # A_config_C_buf_str += "\tsky130_fd_sc_hd__buf_2 A_config_C_outbuf_"+str(j)+" (.A(A_config_C_buf["+str(j)+"]), .X(A_config_C["+str(j)+"]));\n"
        # B_config_C_buf_str += "\tsky130_fd_sc_hd__buf_2 B_config_C_outbuf_"+str(j)+" (.A(B_config_C_buf["+str(j)+"]), .X(B_config_C["+str(j)+"]));\n"
    
    # wrapper_top_str+=I_top_buf_str+'\n'
    # wrapper_top_str+=T_top_buf_str+'\n'
    # wrapper_top_str+=O_top_buf_str+'\n'
    # wrapper_top_str+=A_config_C_buf_str+'\n'
    # wrapper_top_str+=B_config_C_buf_str+'\n'
    
    for row in range(NumberOfRows):
        data_reg_module_temp =""
        
        data_reg_name = 'Frame_Data_Reg_'+str(row)
        wrapper_top_str+='\t'+data_reg_name+' Inst_'+data_reg_name+' (\n'
        wrapper_top_str+='\t.FrameData_I(LocalWriteData),\n'
        wrapper_top_str+='\t.FrameData_O(FrameRegister['+str(row)+'*FrameBitsPerRow+:FrameBitsPerRow]),\n'
        wrapper_top_str+='\t.RowSelect(RowSelect),\n'
        wrapper_top_str+='\t.CLK(CLK)\n'
        wrapper_top_str+='\t);\n\n'
        #data_reg_modules += 'module '+data_reg_name+' (FrameData_I, FrameData_O, RowSelect, CLK);'
        try:
            with open("fabulous_top_wrapper_temp/Frame_Data_Reg_template.v", 'r') as file :
                data_reg_module_temp = file.read()
        except IOError:
            print("Frame_Data_Reg_template.v not accessible")
            break
        data_reg_module_temp=data_reg_module_temp.replace("Frame_Data_Reg", data_reg_name)
        data_reg_module_temp=data_reg_module_temp.replace("parameter FrameBitsPerRow = 32", "parameter FrameBitsPerRow = "+str(FrameBitsPerRow))
        data_reg_module_temp=data_reg_module_temp.replace("parameter RowSelectWidth = 5", "parameter RowSelectWidth = "+str(RowSelectWidth))
        data_reg_module_temp=data_reg_module_temp.replace("parameter Row = 1", "parameter Row = "+str(row+1))
        data_reg_modules += data_reg_module_temp+'\n\n'
        #with open("verilog_output/"+data_reg_name+".v", 'w') as file:
        #    file.write(data_reg_module_temp)
        
    for col in range(NumberOfCols):
        strobe_reg_module_temp =""
        
        strobe_reg_name = 'Frame_Select_'+str(col)
        wrapper_top_str+='\t'+strobe_reg_name+' Inst_'+strobe_reg_name+' (\n'
        wrapper_top_str+='\t.FrameStrobe_I(FrameAddressRegister[MaxFramesPerCol-1:0]),\n'
        wrapper_top_str+='\t.FrameStrobe_O(FrameSelect['+str(col)+'*MaxFramesPerCol +: MaxFramesPerCol]),\n'
        wrapper_top_str+='\t.FrameSelect(FrameAddressRegister[FrameBitsPerRow-1:FrameBitsPerRow-(FrameSelectWidth)]),\n'
        wrapper_top_str+='\t.FrameStrobe(LongFrameStrobe)\n'
        wrapper_top_str+='\t);\n\n'
        try:
            with open("fabulous_top_wrapper_temp/Frame_Select_template.v", 'r') as file :
                strobe_reg_module_temp = file.read()
        except IOError:
            print("Frame_Select_template.v not accessible")
            break
        strobe_reg_module_temp=strobe_reg_module_temp.replace("Frame_Select", strobe_reg_name)
        strobe_reg_module_temp=strobe_reg_module_temp.replace("parameter MaxFramesPerCol = 20", "parameter MaxFramesPerCol = "+str(MaxFramesPerCol))
        strobe_reg_module_temp=strobe_reg_module_temp.replace("parameter FrameSelectWidth = 5", "parameter FrameSelectWidth = "+str(FrameSelectWidth))
        strobe_reg_module_temp=strobe_reg_module_temp.replace("parameter Col = 18", "parameter Col = "+str(col))
        strobe_reg_modules += strobe_reg_module_temp+'\n\n'
        #with open("verilog_output/"+strobe_reg_name+".v", 'w') as file:
        #    file.write(strobe_reg_module_temp)

    #wrapper_top_str+='\twire ['+str(NumberOfRows-1)+':0] dump;\n\n'
    wrapper_top_str+='\teFPGA Inst_eFPGA(\n'
    
    I_top_str =""
    T_top_str = ""
    O_top_str = ""
    count = 0
    for i in range(NumberOfRows*4-1,-1,-4):
        count += 1
        I_top_str+='\t.Tile_X0Y'+str(count)+'_A_I_top(I_top['+str(i)+']),\n'
        I_top_str+='\t.Tile_X0Y'+str(count)+'_B_I_top(I_top['+str(i-1)+']),\n'
        I_top_str+='\t.Tile_X' + str(NumberOfCols-1) + 'Y'+str(count)+'_A_I_top(I_top['+str(i-2)+']),\n'
        I_top_str+='\t.Tile_X' + str(NumberOfCols-1) + 'Y'+str(count)+'_B_I_top(I_top['+str(i-3)+']),\n'

        T_top_str+='\t.Tile_X0Y'+str(count)+'_A_T_top(T_top['+str(i)+']),\n'
        T_top_str+='\t.Tile_X0Y'+str(count)+'_B_T_top(T_top['+str(i-1)+']),\n'
        T_top_str+='\t.Tile_X' + str(NumberOfCols-1) + 'Y'+str(count)+'_A_T_top(T_top['+str(i-2)+']),\n'
        T_top_str+='\t.Tile_X' + str(NumberOfCols-1) + 'Y'+str(count)+'_B_T_top(T_top['+str(i-3)+']),\n'

        O_top_str+='\t.Tile_X0Y'+str(count)+'_A_O_top(O_top['+str(i)+']),\n'
        O_top_str+='\t.Tile_X0Y'+str(count)+'_B_O_top(O_top['+str(i-1)+']),\n'
        O_top_str+='\t.Tile_X' + str(NumberOfCols-1) + 'Y'+str(count)+'_A_O_top(O_top['+str(i-2)+']),\n'
        O_top_str+='\t.Tile_X' + str(NumberOfCols-1) + 'Y'+str(count)+'_B_O_top(O_top['+str(i-3)+']),\n'

    A_config_C_str =""
    B_config_C_str =""
    
    FAB2RAM_C_str =""
    Config_accessC_str =""

    count = 0
    for i in range(NumberOfRows*4-1,-1,-4):
        count += 1
        A_config_C_str+='\t.Tile_X0Y'+str(count)+'_A_config_C_bit0(A_config_C['+str(i)+']),\n'
        A_config_C_str+='\t.Tile_X0Y'+str(count)+'_A_config_C_bit1(A_config_C['+str(i-1)+']),\n'
        A_config_C_str+='\t.Tile_X0Y'+str(count)+'_A_config_C_bit2(A_config_C['+str(i-2)+']),\n'
        A_config_C_str+='\t.Tile_X0Y'+str(count)+'_A_config_C_bit3(A_config_C['+str(i-3)+']),\n'
        
        B_config_C_str+='\t.Tile_X0Y'+str(count)+'_B_config_C_bit0(B_config_C['+str(i)+']),\n'
        B_config_C_str+='\t.Tile_X0Y'+str(count)+'_B_config_C_bit1(B_config_C['+str(i-1)+']),\n'
        B_config_C_str+='\t.Tile_X0Y'+str(count)+'_B_config_C_bit2(B_config_C['+str(i-2)+']),\n'
        B_config_C_str+='\t.Tile_X0Y'+str(count)+'_B_config_C_bit3(B_config_C['+str(i-3)+']),\n'
        
    RAM2FAB_D_str =""
    FAB2RAM_D_str =""
    count = 0
    
    # for i in range(NumberOfRows*4*4-1-12,-1,-15):
        # count += 1
        # RAM2FAB_D_str+='\t.Tile_X'+str(NumberOfCols-1)+'Y'+str(count)+'_RAM2FAB_D0_I0(RAM2FAB_D['+str(i)+']),\n'
        # RAM2FAB_D_str+='\t.Tile_X'+str(NumberOfCols-1)+'Y'+str(count)+'_RAM2FAB_D0_I1(RAM2FAB_D['+str(i-1)+']),\n'
        # RAM2FAB_D_str+='\t.Tile_X'+str(NumberOfCols-1)+'Y'+str(count)+'_RAM2FAB_D0_I2(RAM2FAB_D['+str(i-2)+']),\n'
        # RAM2FAB_D_str+='\t.Tile_X'+str(NumberOfCols-1)+'Y'+str(count)+'_RAM2FAB_D0_I3(RAM2FAB_D['+str(i-3)+']),\n'
        # RAM2FAB_D_str+='\t.Tile_X'+str(NumberOfCols-1)+'Y'+str(count)+'_RAM2FAB_D1_I0(RAM2FAB_D['+str(i-4)+']),\n'
        # RAM2FAB_D_str+='\t.Tile_X'+str(NumberOfCols-1)+'Y'+str(count)+'_RAM2FAB_D1_I1(RAM2FAB_D['+str(i-5)+']),\n'
        # RAM2FAB_D_str+='\t.Tile_X'+str(NumberOfCols-1)+'Y'+str(count)+'_RAM2FAB_D1_I2(dump['+str(NumberOfRows-count)+']),\n'
        # RAM2FAB_D_str+='\t.Tile_X'+str(NumberOfCols-1)+'Y'+str(count)+'_RAM2FAB_D1_I3(RAM2FAB_D['+str(i-6)+']),\n'
        # RAM2FAB_D_str+='\t.Tile_X'+str(NumberOfCols-1)+'Y'+str(count)+'_RAM2FAB_D2_I0(RAM2FAB_D['+str(i-7)+']),\n'
        # RAM2FAB_D_str+='\t.Tile_X'+str(NumberOfCols-1)+'Y'+str(count)+'_RAM2FAB_D2_I1(RAM2FAB_D['+str(i-8)+']),\n'
        # RAM2FAB_D_str+='\t.Tile_X'+str(NumberOfCols-1)+'Y'+str(count)+'_RAM2FAB_D2_I2(RAM2FAB_D['+str(i-9)+']),\n'
        # RAM2FAB_D_str+='\t.Tile_X'+str(NumberOfCols-1)+'Y'+str(count)+'_RAM2FAB_D2_I3(RAM2FAB_D['+str(i-10)+']),\n'
        # RAM2FAB_D_str+='\t.Tile_X'+str(NumberOfCols-1)+'Y'+str(count)+'_RAM2FAB_D3_I0(RAM2FAB_D['+str(i-11)+']),\n'
        # RAM2FAB_D_str+='\t.Tile_X'+str(NumberOfCols-1)+'Y'+str(count)+'_RAM2FAB_D3_I1(RAM2FAB_D['+str(i-12)+']),\n'
        # RAM2FAB_D_str+='\t.Tile_X'+str(NumberOfCols-1)+'Y'+str(count)+'_RAM2FAB_D3_I2(RAM2FAB_D['+str(i-13)+']),\n'
        # RAM2FAB_D_str+='\t.Tile_X'+str(NumberOfCols-1)+'Y'+str(count)+'_RAM2FAB_D3_I3(RAM2FAB_D['+str(i-14)+']),\n'
    
        
        
    
    wrapper_top_str+=I_top_str+'\n'
    wrapper_top_str+=T_top_str+'\n'
    wrapper_top_str+=O_top_str+'\n'
    wrapper_top_str+=A_config_C_str+'\n'
    wrapper_top_str+=B_config_C_str+'\n'
    
    
    wrapper_top_str+='\t//declarations\n'
    wrapper_top_str+='\t.UserCLK(CLK),\n'
    wrapper_top_str+='\t.FrameData(FrameData),\n'
    wrapper_top_str+='\t.FrameStrobe(FrameSelect)\n'
    wrapper_top_str+='\t);\n\n'
    
        
    wrapper_top_str+="\tassign FrameData = {32'h12345678,FrameRegister,32'h12345678};\n\n"
    wrapper_top_str+='endmodule\n\n'

    # wrapper_top_str+='module sky130_fd_sc_hd__inv (\n'
    # wrapper_top_str+='\tY,\n'
    # wrapper_top_str+='\tA\n'
    # wrapper_top_str+='\t);\n'
    # wrapper_top_str+='\toutput Y;\n'
    # wrapper_top_str+='\tinput  A;\n'
    # wrapper_top_str+='\n'
    # wrapper_top_str+='\tassign Y=~A;\n'
    # wrapper_top_str+='endmodule\n'
    #wrapper_top_str+=data_reg_modules
    #wrapper_top_str+=strobe_reg_modules
        
    if wrapper_top_str:
        with open("eFPGA_top.v", 'w') as file:
            file.write(wrapper_top_str)

    if data_reg_modules:
        with open("Frame_Data_Reg_Pack.v", 'w') as file:
            file.write(data_reg_modules)

    if strobe_reg_modules:
        with open("Frame_Select_Pack.v", 'w') as file:
            file.write(strobe_reg_modules)
        
    if config_str:
        with open("Config.v", 'w') as file:
            file.write(config_str)
        
    if configfsm_str:
        with open("ConfigFSM.v", 'w') as file:
            file.write(configfsm_str)
        
    #if testbench_str:
    #    with open("tb_bitbang.vhd", 'w') as file:
    #        file.write(testbench_str)
    
    print("Finish")

if __name__ == "__main__":
    main(sys.argv[1:])


#argv = "/home/ise/shared_folder/diffeq1/LC_on/netgen/synthesis/diffeq_paj_convert_synthesis.v"



#if words[i+1] == "critical":
#number1.append(words[i+3])
#elif x == "Total":
#if words[i+1] == "used":
#number2.append(words[i+5])
#print(number1)
#print(number2)
