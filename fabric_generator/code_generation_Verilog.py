from typing import Literal
import math
import re

from fabric_generator.fabric import Tile, Bel, ConfigBitMode, IO
from fabric_generator.code_generator import codeGenerator


class VerilogWriter(codeGenerator):
    """
    The writer class for generating Verilog code.
    """

    def addComment(self, comment, onNewLine=False, end="", indentLevel=0) -> None:
        if onNewLine:
            self._add("")
        if self._content:
            self._content[-1] += f"{' ':<{indentLevel*4}}" + \
                f"//{comment}"f"{end}"
        else:
            self._add(f"{' ':<{indentLevel*4}}" +
                      f"// {comment}"f"{end}")

    def addHeader(self, name, package='', indentLevel=0):
        self._add(f"module {name}", indentLevel)

    def addHeaderEnd(self, name, indentLevel=0):
        pass

    def addParameterStart(self, indentLevel=0):
        self._add(f"#(", indentLevel)

    def addParameterEnd(self, indentLevel=0):
        self._add(")", indentLevel)

    def addParameter(self, name, type, value, end=False, indentLevel=0):
        if end:
            self._add(f"parameter {name}={value}", indentLevel)
        else:
            self._add(f"parameter {name}={value},", indentLevel)

    def addPortStart(self, indentLevel=0):
        self._add(f"(", indentLevel)

    def addPortEnd(self, indentLevel=0):
        self._add(");", indentLevel)

    def addPortScalar(self, name, io: IO, end=False, indentLevel=0):
        ioString = io.value.lower()
        if end:
            self._add(f"{ioString} {name}", indentLevel)
        else:
            self._add(f"{ioString} {name},", indentLevel)

    def addPortVector(self, name, io: IO, msbIndex, end=False, indentLevel=0):
        ioString = io.value.lower()
        if end:
            self._add(f"{ioString} [{msbIndex}:0] {name}", indentLevel)
        else:
            self._add(f"{ioString} [{msbIndex}:0] {name},", indentLevel)

    def addDesignDescriptionStart(self, name, indentLevel=0):
        pass

    def addDesignDescriptionEnd(self, indentLevel=0):
        self._add("endmodule", indentLevel)

    def addConstant(self, name, value, indentLevel=0):
        self._add(f"parameter {name} = {value};", indentLevel)

    def addConnectionScalar(self, name, indentLevel=0):
        self._add(f"wire {name};", indentLevel)

    def addConnectionVector(self, name, startIndex, endIndex=0, indentLevel=0):
        self._add(
            f"wire[{startIndex}:{endIndex}] {name};", indentLevel)

    def addLogicStart(self, indentLevel=0):
        pass

    def addLogicEnd(self, indentLevel=0):
        pass

    def addInstantiation(self, compName, compInsName, compPorts, signals, paramPorts=[], paramSignals=[], indentLevel=0):
        if len(compPorts) != len(signals):
            raise ValueError(
                f"Number of ports and signals do not match: {compPorts} != {signals}")
        if len(paramPorts) != len(paramSignals):
            raise ValueError(
                f"Number of ports and signals do not match: {paramPorts} != {paramSignals}")

        if paramPorts:
            port = [f".{paramPorts[i]}({paramSignals[i]})" for i in range(
                len(paramPorts))]
            self._add(
                f"{compName} {compInsName}", indentLevel=indentLevel)
            self._add("#(", indentLevel=indentLevel+1)
            self._add(
                (",\n"f"{' ':<{4*(indentLevel + 1)}}").join(port), indentLevel=indentLevel + 1)
            self._add(") (", indentLevel=indentLevel+1)
        else:
            self._add(f"{compName} {compInsName} (", indentLevel=indentLevel)

        connectPair = []
        for i in range(len(compPorts)):
            if "(" in signals[i]:
                signals[i] = signals[i].replace("(", "[").replace(")", "]")
            connectPair.append(f".{compPorts[i]}({signals[i]})")

        self._add(
            (",\n"f"{' ':<{4*(indentLevel + 1)}}").join(connectPair), indentLevel=indentLevel + 1)
        self._add(");", indentLevel=indentLevel)
        self.addNewLine()

    def addComponentDeclarationForFile(self, fileName):
        configPortUsed = 0  # 1 means is used
        with open(fileName, 'r') as f:
            data = f.read()

        if result := re.search(r"NumberOfConfigBits.*?(\d+)", data, flags=re.IGNORECASE):
            configPortUsed = 1
            if result.group(1) == '0':
                configPortUsed = 0

        return configPortUsed

    def addShiftRegister(self, configBits, indentLevel=0):
        template = f"""
// the configuration bits shift register
    always @ (posedge CLK)
        begin
            if (MODE=1b'1) begin    //configuration mode
                ConfigBits <= {{CONFin,ConfigBits[{configBits}-1:1]}};
            end
        end
    assign CONFout = ConfigBits[{configBits}-1];

        """
        self._add(template, indentLevel)

    def addFlipFlopChain(self, configBits, indentLevel=0):
        cfgBit = int(math.ceil(configBits/2.0))*2
        template = f"""
    genvar k;
    assign ConfigBitsInput = {{ConfigBits[{cfgBit}-1-1:0], CONFin;}}
    // for k in 0 to Conf/2 generate
    for (k=0; k < {cfgBit-1}; k = k + 1) begin: L
        LHQD1 inst_LHQD1a(
            .D(ConfigBitsInput[k*2]),
            .E(CLK),
            .Q(ConfigBits[k*2])
        );
        LHQD1 inst_LHQD1b(
            .D(ConfigBitsInput[(k*2)+1]),
            .E(MODE),
            .Q(ConfigBits[(k*2)+1])
        );
    end
    assign CONFout = ConfigBits[{cfgBit}-1];
"""
        self._add(template, indentLevel)

    def addAssignScalar(self, left, right, delay=0, indentLevel=0):
        if type(right) == list:
            self._add(f"assign {left} = {{{','.join(right)}}};", indentLevel)
        else:
            self._add(f"assign {left} = {right};")

    def addAssignVector(self, left, right, widthL, widthR, indentLevel=0):
        self._add(
            f"assign {left} = {right}[{widthL}:{widthR}];", indentLevel)

    def addBELInstantiations(self, bel: Bel, configBitCounter, mode=ConfigBitMode.FRAME_BASED, belCounter=0):
        belTemplate = """
{entity} Inst_{prefix}{entity} (
{portList}
    // I/O primitive pins go to tile top level entity (not further parsed)
{globalAndConfigBits}
);
    """
        # internal port
        portList = []
        globalAndConfigBits = []
        for port in bel.inputs + bel.outputs:
            port = re.sub(rf"{bel.prefix}", "", port)
            portList.append(f"{' ':<4}.{port}({bel.prefix}{port}),")

        # normal external port
        for port in bel.externalInput + bel.externalOutput:
            if port not in bel.sharedPort:
                globalAndConfigBits.append(
                    f".{' ':<4}{port}({bel.prefix}{port})")

        # shared port
        # top level I/Os (if any) just get connected directly
        for ports in bel.sharedPort:
            globalAndConfigBits.append(f"{' ':<4}.{ports[0]}({ports[0]})")

        if mode == ConfigBitMode.FRAME_BASED:
            globalAndConfigBits.append(
                f"{' ':<4}.ConfigBits(ConfigBits[{configBitCounter+bel.configBit}-1:{configBitCounter}])")
        elif mode == ConfigBitMode.FLIPFLOP_CHAIN:
            self.add_Conf_Instantiation(belCounter, close=True)

        self._add(belTemplate.format(prefix=bel.prefix,
                                     entity=bel.src.split(
                                         "/")[-1].split(".")[0],
                                     portList='\n'.join(portList),
                                     globalAndConfigBits=',\n'.join(globalAndConfigBits)))

    def add_Conf_Instantiation(self, counter, close=True):
        confTemplate = """
        // GLOBAL all primitive pins for configuration (not further parsed)
            .MODE(Mode),
            .CONFin(conf_data({counter})),
            .CONFout(conf_data({counter2})),
            .CLK(CLK)
            {end}
    """
        self._add(confTemplate.format(counter=counter,
                                      counter2=counter+1,
                                      end='' if close else ');'))
