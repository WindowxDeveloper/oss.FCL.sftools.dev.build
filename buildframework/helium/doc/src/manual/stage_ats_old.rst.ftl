..  ============================================================================ 
    Name        : stage_ats_old.rst.ftl
    Part of     : Helium 
    
    Copyright (c) 2009 Nokia Corporation and/or its subsidiary(-ies).
    All rights reserved.
    This component and the accompanying materials are made available
    under the terms of the License "Eclipse Public License v1.0"
    which accompanies this distribution, and is available
    at the URL "http://www.eclipse.org/legal/epl-v10.html".
    
    Initial Contributors:
    Nokia Corporation - initial contribution.
    
    Contributors:
    
    Description:
    
    ============================================================================

.. index::
  module: TestingOld


===========================
Testing (ATS3/Old Document)
===========================

This is an old version of document for test automation for the **Helium users using ATS3**. 

**ATS4 users** should read `Helium Test Automation User Guide`_ (revised).

.. _`Helium Test Automation User Guide`: stage_ats.html  

.. contents::

  
Stage: ATS - STIF, TEF, RTEST, MTF, SUT and EUnit (also Qt)
===========================================================

ATS testing is the automatic testing of the phone code once it has been compiled and linked to create a ROM image.

Explanation of the process for getting ATS (`STIF`_ and `EUnit`_) tests compiled and executed by Helium, through the use of the :hlm-t:`ats-test` target.

http://developer.symbian.org/wiki/index.php/Symbian_Test_Tools

<#if !(ant?keys?seq_contains("sf"))>
.. _`STIF`: http://s60wiki.nokia.com/S60Wiki/STIF
.. _`EUnit`: http://s60wiki.nokia.com/S60Wiki/EUnit
</#if>

.. image:: ats.dot.png

Prerequisites
-------------

* `Harmonized Test Interface (HTI)`_ needs to be compiled and into the image.
* The reader is expected to already have a working ATS setup in which test cases can be executed.  ATS server names, 
  access rights and authentication etc. is supposed to be already taken care of.

<#if !(ant?keys?seq_contains("sf"))>
.. _`Harmonized Test Interface (HTI)`: http://s60wiki.nokia.com/S60Wiki/HTI
<#else>
.. _`Harmonized Test Interface (HTI)`: http://developer.symbian.org/wiki/index.php/HTI_Tool
</#if>

Test source components
----------------------

Test source usually lives in a component's ``tsrc`` directory.  Test source components are created like any other Symbian SW component; 
there is a ``group`` directory with a ``bld.inf`` file for building, ``.mmp`` files for defining the targets, and so on.

The test generation code expects ``.pkg`` file in the ``group`` directory of test component to be compiled, to get the paths of the files 
(can be data, configuration, initialization, etc files) to be installed and where to install on the phone. 


Three STEPS to setup ATS with Helium
------------------------------------

**Step 1: Configure System Definition Files**
 If the tsrc directory structure meets the criteria defined in the `new API test automation guidelines`_, then test components 
 should be included in the System Definition files.

**System Definition Files supporting layers.sysdef.xml**
 **layers** in ``layers.sysdef.xml`` file and **configuration** in ``build.sysdef.xml`` file (`Structure of System Definition files version 1.4`_).
 
 <#if !(ant?keys?seq_contains("sf"))>
.. _`new API test automation guidelines`: http://s60wiki.nokia.com/S60Wiki/Test_Asset_Guidelines
.. _`Structure of System Definition files version 1.4`: http://delivery.nmp.nokia.com/trac/helium/wiki/SystemDefinitionFiles
</#if>

A template of layer in layers.sysdef.xml for system definition files

.. code-block:: xml

    <layer name="name_test_layer">
        <module name="module_name_one">
            <unit unitID="unit_id1" name="unit_name1" bldFile="path_of_tsrc_folder_to_be_built" mrp="" />
        </module>
        
        <module name="module_name_two">
            <unit unitID="unit_id2" name="unit_name2" bldFile="path_of_tsrc_folder_to_be_built" mrp="" />
        </module>
    </layer> 

* Layer name should end with **_test_layer**
* Two standard names for ATS test layers are being used; ``unit_test_layer`` and ``api_test_layer``. Test components (the``unit`` tags) 
  should be specified under these layers and grouped by ``module`` tag(s).
* In the above, two modules means two drop files will be created; ``module`` may have one or more ``unit``
* By using property ``exclude.test.layers``, complete layers can be excluded and the components inside that layer will not be included in the AtsDrop. This property is a comma (,) separated list

**System Definition Files version 3.0 (SysDefs3)** (new Helium v.10.79)
 The `structure of System Definition files version 3.0`_ is different than previous versions of system definition files. In SysDefs3, package definition files are used for components specification. Instead of layers naming conventions, filters are used to identify test components and test types, for example: "test, unit_test, !api_test" etc.

<#if !(ant?keys?seq_contains("sf"))>
.. _`structure of System Definition files version 3.0`: http://wikis.in.nokia.com/view/SWManageabilityTeamWiki/PkgdefUse
<#else>
.. _`structure of System Definition files version 3.0`: sysdef3.html
</#if>

An example template for defining test components in a package definition file.

.. code-block:: xml

      <package id="dummytest" name="dummytest" levels="demo">
        <collection id="test_nested" name="test_nested" level="demo">
        
          <component id="tc1" name="tc1" purpose="development" filter="test, unit_test">
              <unit bldFile="test_nested/tc1/group" mrp="" />
          </component>
          
          <component id="tc2" name="tc2" purpose="development" filter="test">
            <meta rel="testbuild">
              <group name="drop_tc2_and_tc3" /> 
            </meta>
            <unit bldFile="test_nested/tc2/group" mrp="" />
          </component>
          
          <component id="tc3" name="tc3" purpose="development" filter="test">
            <meta rel="testbuild">
              <group name="drop_tc2_and_tc3" /> 
            </meta>
            <unit bldFile="test_nested/tc3/group" mrp="" />
          </component>
          
        </collection>
      </package>

* Filter "test" must be specified for every test component. If it is not specified, the component will not be considered as a test component.
* <meta>/<group> are now used to group test components, it work in the same way as <module>...<module> in sysdef v1.4 works. The components having same group name are grouped together. 
  Separate drop files are created for different groups. In the above example, if only 'test' is selected, then two drop files will be created, one with tc1 and the other one with tc2 and tc3. 


**Step 2: Configure ATS properties in build.xml**

**(A)** Username and Password for the ATS should be set in the `.netrc file`_::

    machine ats login ats_user_name password ats_password

Add the above line in the ``.netrc`` file and replace ``ats_user_name`` with your real ATS username and ``ats_password`` with ATS password.
    
**(B)** The following properties are ATS dependent with their edit status

* [must] - must be set by user
* [recommended] - should be set by user but not mandatory
* [allowed] - should **not** be set by user however, it is possible.

.. csv-table:: ATS Ant properties
   :header: "Property name", "Edit status", "Description"
   
    ":hlm-p:`ats.server`", "[must]", "For example: ``4fix012345`` or ``catstresrv001.company.net:80``. Default server port is ``8080``, but it is not allowed between intra and Noklab. Because of this we need to define server port as 80. The host can be different depending on site and/or product."
    ":hlm-p:`ats.drop.location`", "[allowed]", "Server location (UNC path) to save the ATSDrop file, before sending to the ATS Server. For example: ``\\\\trwsem00\\some_folder\\``. In case, :hlm-p:`ats.script.type` is set to ``import``, ATS doesn't need to have access to :hlm-p:`ats.drop.location`,  its value can be any local folder on build machine, for example ``c:/temp`` (no network share needed)."
    ":hlm-p:`ats.product.name`", "[must]", "Name of the product to be tested."
    ":hlm-p:`eunit.test.package`", "[allowed]", "The EUnit package name to be unzipped on the environment, for executing EUnit tests."
    ":hlm-p:`eunitexerunner.flags`", "[allowed]", "Flags for EUnit exerunner can be set by setting the value of this variable. The default flags are set to ``/E S60AppEnv /R Off``."
    ":hlm-p:`ats.email.list`", "[allowed]", "The property is needed if you want to get an email from ATS server after the tests are executed. There can be one to many semicolon-separated email addresses."
    ":hlm-p:`ats.report.type`", "[allowed]", "Value of the ats email report, for ATS4 set to 'no_attachment' so email size is reduced"
    ":hlm-p:`ats.flashfiles.minlimit`", "[allowed]", "Limit of minimum number of flash files to execute :hlm-t:`ats-test` target, otherwise ``ATSDrop.zip`` will not be generated. Default value is 2 files."
    ":hlm-p:`ats.plan.name`", "[allowed]", "Modify the plan name if you have understanding of ``test.xml`` file or leave it as it is. Default value is ``plan``."
    ":hlm-p:`ats.product.hwid`", "[allowed]", "Product HardWare ID (HWID) attached to ATS. By default the value of HWID is not set."
    ":hlm-p:`ats.script.type`", "[allowed]", "There are two types of ats script files to send drop to ATS server, ``runx`` and ``import``; only difference is that with ``import`` ATS doesn't have to have access rights to ``testdrop.zip`` file, as it is sent to the system over http and import doesn't need network shares. If that is not needed ``import`` should not be used. Default value is ``runx`` as ``import`` involves heavy processing on ATS server."
    ":hlm-p:`ats.target.platform`", "[allowed]", "Sets target platform for compiling test components. Default value is ``armv5 urel``."
    ":hlm-p:`ats.test.timeout`", "[allowed]", "To set test commands execution time limit on ATS server, in seconds. Default value is ``60``."
    ":hlm-p:`ats.testrun.name`", "[allowed]", "Modify the test-run name if you have understanding of ``test.xml`` file or leave it as it is. Default value is a string consist of build id, product name, major and minor versions."
    ":hlm-p:`ats.trace.enabled`", "[allowed]", "Should be ``true`` if tracing is needed during the tests running on ATS. Default value is ``false``, the values are case-sensitive. See http://s60wiki.nokia.com/S60Wiki/CATS/TraceTools."
    ":hlm-p:`ats.ctc.enabled`", "[allowed]", "Should be ``true`` if coverage measurement and dynamic analysis (CTC) tool support is to be used by ATS. Default value is ``false``. The values are case-sensitive."
    ":hlm-p:`ats.ctc.host`", "[allowed]", "ATS3 only CTC host, provided by CATS used to create coverage measurement reports. MON.sym files are copied to this location, for example ``10.0.0.1``. If not given, code coverage reports are not created"
    ":hlm-p:`ats.obey.pkgfiles.rule`", "[allowed]", "If the property is set to ``true``, then the only test components which will have PKG files, will be included into the ``test.xml`` as a test-set. Which means, even if there's a test component (executable) but there's no PKG file, it should not be considered as a test component and hence not included into the test.xml as a separate test. By default the property value is ``false``."
    ":hlm-p:`tsrc.data.dir`", "[allowed]", "The default value is ``data`` and refers to the 'data' directory under 'tsrc' directory."
    ":hlm-p:`tsrc.path.list`", "[allowed]", "Contains list of the tsrc directories. Gets the list from system definition layer files. Assuming that the test components are defined already in te ``layers.sysdef.xml`` files to get compiled. Not recommended, but the property value can be set if there are no System Definition file(s), and tsrc directories paths to set manually."
    ":hlm-p:`ats.report.location`", "[allowed]", "Sets ATS reports store location. Default location is ``${r'$'}{publish.dir}/${r'$'}{publish.subdir}``."
    ":hlm-p:`ats.multiset.enabled`", "[allowed]", "Should be ``true`` so a set is used for each pkg file in a component, this allows tests to run in parallel on several devices."
    ":hlm-p:`ats.diamonds.signal`", "[allowed]", "Should be ``true`` so at end of the build diamonds is checked for test results and Helium fails if tests failed."
    ":hlm-p:`ats.delta.enabled`", "[allowed]", "Should be ``true`` so only ADOs changed during :hlm-t:`do-prep-work-area` are tested by ATS."
    ":hlm-p:`ats4.enabled`", "[allowed]", "Should be ``true`` if ATS4 is to be used."
    ":hlm-p:`ats.emulator.enable`", "[allowed]", "Should be ``true`` if ``WINSCW`` emulator is to be used."
    ":hlm-p:`ats.specific.pkg`", "[allowed]", "Text in name of PKG files to use eg. 'sanity' would only use xxxsanity.pkg files from components."
    ":hlm-p:`ats.singledrop.enabled`", "[allowed]", "If present and set to 'true', it will create one drop file, if set to any other value or not present it will create multiple drop files (defined by the sysdef file). This is to save traffic to the server."
    ":hlm-p:`ats.java.importer.enabled`", "[allowed]", "If set to 'true', for older uploader is used for ats3 which shows improved error message."
    ":hlm-p:`ats.test.filterset`", "[allowed]", "(new Helium v.10.79)Contains a name of test filterset (see example below). A filterset is used to select/unselect test components. The filter(s) is/are effective when the same filters are defined in the package definition file for component(s)."

An example of setting up properties:

.. code-block:: xml

    <property name="ats.server" value="4fio00105"  />
    <property name="ats.drop.location" location="\\trwsimXX\ATS_TEST_SHARE\" />
    <property name="ats.email.list" value="temp.user@company.com; another.email@company.com" />
    <property name="ats.flashfiles.minlimit" value="2" />
    <property name="ats.product.name" value="PRODUCT" />
    <property name="ats.plan.name" value="plan" />
    <property name="ats.product.hwid" value="" />
    <property name="ats.script.type" value="runx" />
    <property name="ats.target.platform" value="armv5 urel" />
    <property name="ats.test.timeout" value="60" />
    <property name="ats.testrun.name" value="${r'$'}{build.id}_${r'$'}{ats.product.name}_${r'$'}{major.version}.${r'$'}{minor.version}" />
    <property name="ats.trace.enabled" value="false" />
    <property name="ats.ctc.enabled" value="false" />
    <property name="ats.obey.pkgfiles.rule" value="false" />
    <property name="ats.report.location" value="${r'$'}{publish.dir}/${r'$'}{publish.subdir}" />
    <property name="eunit.test.package" value="" />
    <property name="eunitexerunner.flags" value="/E S60AppEnv /R Off" />
    <property name="ats.test.filterset" value="sysdef.filters.tests" />

    <hlm:sysdefFilterSet id="sysdef.filters.tests">
        <filter filter="test, " type="has" />
        <config file="bldvariant.hrh" includes="" />
    </hlm:sysdefFilterSet>

.. Note::
   
   Always declare *Properties* before and *filesets* after importing helium.ant.xml.

**STEP 3: Call target ats-test**

To execute the target, a property should be set(``<property name="ats.enabled" value="true" />``).

Then call :hlm-t:`ats-test`, which will create the ATSDrop.zip (test package).

If property *ats.email.list* is set, an email (test report) will be sent when the tests are ready on ATS.

CTC
---

* To enable ctc for ATS set, :hlm-p:`ats.ctc.enabled`.

For ATS3 only, set the ftp hostname for the ATS server:

.. code-block:: xml
    
    <property name="ats.ctc.host" value="1.2.3"/>
    
    
* To compile components for CTC see `configure CTC for SBS`_ 

.. _`configure CTC for SBS`: ../helium-antlib/sbsctc.html


* Once ATS tests have finished results for CTC will be shown in Diamonds.
* The following are optional CTC properties

.. csv-table:: Table: ATS Ant properties
   :header: "Property name", "Edit status", "Description"
   
    "``ctc.instrument.type``", "[allowed]", "Sets the instrument type"
    "``ctc.build.options``", "[allowed]", "Enables optional extra arguments for CTC, after importing a parent ant file."


For example,

.. code-block:: xml
    
    <property name="ctc.instrument.type" value="m" />

    <import file="../../build.xml" />
    
    <hlm:argSet id="ctc.build.options">
        <arg line="-C OPT_ADD_COMPILE+-DCTC_NO_START_CTCMAN" />
    </hlm:argSet>

Or

.. code-block:: xml

    <hlm:argSet id="ctc.build.options">
        <arg line='-C "EXCLUDE+*\sf\os\xyz\*,*\tools\xyz\*"'/>
    </hlm:argSet>


See `more information on code coverage`_

<#if !(ant?keys?seq_contains("sf"))>
.. _`more information on code coverage`: http://s60wiki.nokia.com/S60Wiki/CTC
<#else>
.. _`more information on code coverage`: http://developer.symbian.org/wiki/index.php/Testing_Guidelines_for_Package_Releases#Code_coverage
</#if>







Qt Tests
--------

QtTest.lib is supported and the default harness is set to EUnit. If ``QtTest.lib`` is there in ``.mmp`` file, Helium sets the Harness to Eunit and ATS supported Qt steps are added to test.xml file

In ``layers.sysdef.xml`` file, the layer name should end with "_test_layer" e.g. "qt_unit_test_layer".

There are several ``.PKG`` files created after executing ``qmake``, but only one is selected based on which target platform is set. Please read the property (:hlm-p:`ats.target.platform`) description above.

.. _`Skip-Sending-AtsDrop-label`:

Skip Sending AtsDrop to ATS
---------------------------

By setting property of :hlm-p:`ats.upload.enabled` to ``false``, ``ats-test`` target only creates a drop file, and does not send the drop (or package) to ATS server.

Choosing images to send to ATS
------------------------------

Since helium 10 images are picked up using :hlm-p:`ats.product.name` and Imaker iconfig.xml files. ``release.images.dir`` is searched for iconfig.xml files, the ones where the product name is part of :hlm-p:`ats.product.name` is used.

You should only build the images for each product you want to include in ats. Eg.

.. code-block:: xml

    <hlm:imakerconfigurationset id="configname">
        <imakerconfiguration>
            <hlm:product list="${r'$'}{product.list}" ui="true"/>
            <targetset>
                <include name="^core${r'$'}"/>
                <include name="^langpack_01${r'$'}"/>
                <include name="^custvariant_01_tools${r'$'}"/>
                <include name="^udaerase${r'$'}"/>
            </targetset>
            <variableset>
                <variable name="TYPE" value="rnd"/>
            </variableset>
        </imakerconfiguration>
    </hlm:imakerconfigurationset> 

For older products where there are no iconfig.xml, ``reference.ats.flash.images`` is used:

.. code-block:: xml

    <fileset id="reference.ats.flash.images" dir="${r'$'}{release.images.dir}">
        <include name="**/${r'$'}{build.id}*.core.fpsx"/>
        <include name="**/${r'$'}{build.id}*.rofs2.fpsx"/>
        <include name="**/${r'$'}{build.id}*.rofs3.fpsx"/>
    </fileset>

Customizing the test.xml in ATS
-------------------------------

The user can customize the generated test.xml with files:

* **preset_custom.xml** goes before first set
* **postset_custom.xml** goes after last set
* **precase_custom.xml** goes before first case 
* **postcase_custom.xml** goes after last case
* **prestep_custom.xml** goes before first step
* **poststep_custom.xml** goes after last step
* **prerun_custom.xml** goes before first run or execute step
* **postrun_custom.xml** goes after last run or execute step
* **prepostaction.xml** goes before first postaction
* **postpostaction.xml** goes after last postaction

The files must be in the directory 'custom' under the 'tsrc' or 'group' folder to be processed. 

The files need to be proper XML snippets that fit to their place. In case of an error an error is logged and a comment inserted to the generated XML file.

A postaction section customization file (prepostaction.xml or postpostaction.xml) could look like this

.. code-block:: xml

  <postAction>
    <type>Pre PostAction from custom file</type> 
    <params>
       <param name="foo2" value="bar2" /> 
    </params>
  </postAction>
  


The ``prestep_custom.xml`` can be used to flash and unstall something custom.

.. code-block:: xml

  <step name="Install measurement tools" harness="STIF" significant="false">
    <!-- Copy SIS-packages to DUT -->
    <command>install</command>
    <params>
        <param src="Nokia_Energy_Profiler_1_1.sisx"/>
        <param dst="c:\data\Nokia_Energy_Profiler_1_1.sisx"/>
    </params>
    ...
  </step>


And then the  ``prerun_custom.xml`` can be used to start measuring.

.. code-block:: xml

  <step name="Start measurement" harness="STIF" significant="false">
      <!-- Start measurement -->
      <command>execute</command>
      <params>
          <param file="neplauncher.exe"/>
          <param parameters="start c:\data\nep.csv"/>
          <param timeout="30"/>
      </params>
  </step>



**Note:** The users is expected to check the generated test.xml manually, as there is no validation. Invalid XML input files will be disregarded and a comment will be inserted to the generated XML file.

Overriding Test xml values
--------------------------

Set the property ``ats.config.file`` to the location of the config file.

Example configuration:

.. code-block:: xml

    <ATSConfigData>  
        <config name="common" abstract="true">
         
            <!-- Properties to add/ modify -->
            <config type="properties">
               <set name="HARNESS" value="STIF" />
               <set name="2" value="3" />
            </config>
            
            <!-- Settings to add/ modify -->
            <config type="settings">
               <set name="HARNESS" value="STIF" />
               <set name="2" value="3" />
            </config>
            
            <!-- Attributes to modify -->
            <config type="attributes">
               <set name="xyz" value="2" />
               <set name="significant" value="true" />
            </config>
        </config>
    </ATSConfigData>


.. index::
  single: ATS - ASTE

Stage: ATS - ASTE
=================

Explanation of the process for getting ATS `ASTE`_ tests compiled and executed by Helium, through the use of the :hlm-t:`ats-aste` target.

<#if !(ant?keys?seq_contains("sf"))>
.. _`ASTE`: http://s60wiki.nokia.com/S60Wiki/ASTE
</#if>

Prerequisites
-------------

* `Harmonized Test Interface (HTI)`_ needs to be compiled and into the image.
* The reader is expected to already have a working ATS setup in which test cases can be executed.  ATS server names, access rights and authentication etc. is supposed to be already taken care of.
* `SW Test Asset`_ location and type of test should be known.

<#if !(ant?keys?seq_contains("sf"))>
.. _`Harmonized Test Interface (HTI)`: http://s60wiki.nokia.com/S60Wiki/HTI
.. _`SW Test Asset`: http://s60wiki.nokia.com/S60Wiki/MC_SW_Test_Asset_documentation
</#if>

Test source components
----------------------

Unlike STIF, EUnit etc tests, test source components (or ``tsrc`` structure) is not needed for `ASTE`_ tests.

Two STEPS to setup ASTE with Helium
-----------------------------------

**STEP 1: Configure ASTE properties in build.xml**

**(A)** Username and Password for the ATS should be set in the `.netrc file`_

.. code-block:: text

    machine ats login ats_user_name password ats_password

Add the above line in the .netrc file and replace *ats_user_name* with your real ats username and "ats_password" with ats password.
    
.. _`.netrc file`: configuring.html?highlight=netrc#passwords


**(B)** The following properties are ASTE dependent with their edit status

* [must] - must be set by user
* [recommended] - should be set by user but not mandatory
* [allowed] - should **not** be set by user however, it is possible.

.. csv-table:: ATS Ant properties
   :header: "Property name", "Edit status", "Description"
   
    ":hlm-p:`ats.server`", "[must]", "For example: ``4fio00105`` or ``catstresrv001.company.net:80``. Default server port is ``8080``, but it is not allowed between intra and Noklab. Because of this we need to define server port as ``80``. The host can be different depending on site and/or product."
    ":hlm-p:`ats.drop.location`", "[must]", "Server location (UNC path) to save the ATSDrop file, before sending to the ATS. For example: ``\\\\trwsem00\\some_folder\\``. In case, ``ats.script.type`` is set to ``import``, ATS doesn't need to have access to :hlm-p:`ats.drop.location`,  its value can be any local folder on build machine, for example ``c:/temp`` (no network share needed)."
    ":hlm-p:`ats.product.name`", "[must]", "Name of the product to be tested."
    ":hlm-p:`ats.aste.testasset.location`", "[must]", "Location of SW Test Assets, if the TestAsset is not packaged then it is first compressed to a ``.zip`` file. It should be a UNC path."
    ":hlm-p:`ats.aste.software.release`", "[must]", "Flash images releases, for example 'SPP 51.32'."
    ":hlm-p:`ats.aste.software.version`", "[must]", "Version of the software to be tested. For example: 'W810'"
    ":hlm-p:`ats.aste.email.list`", "[recommended]", "The property is needed if you want to get an email from ATS server after the tests are executed. There can be one to many semicolon(s) ";" separated email addresses."
    ":hlm-p:`ats.flashfiles.minlimit`", "[recommended]", "Limit of minimum number of flash files to execute ats-test target, otherwise ATSDrop.zip will not be generated. Default value is "2" files."
    ":hlm-p:`ats.aste.plan.name`", "[recommended]", "Modify the plan name if you have understanding of test.xml file or leave it as it is. Default value is "plan"."
    ":hlm-p:`ats.product.hwid`", "[recommended]", "Product HardWare ID (HWID) attached to ATS. By default the value of HWID is not set."
    ":hlm-p:`ats.test.timeout`", "[recommended]", "To set test commands execution time limit on ATS server, in seconds. Default value is '60'."
    ":hlm-p:`ats.aste.testrun.name`", "[recommended]", "Modify the test-run name if you have understanding of ``test.xml`` file or leave it as it is. Default value is a string consists of build id, product name, major and minor versions."
    ":hlm-p:`ats.aste.test.type`", "[recommended]", "Type of test to run. Default is 'smoke'."
    ":hlm-p:`ats.aste.testasset.caseids`", "[recommended]", "These are the cases that which tests should be run from the TestAsset. For example, value can be set as ``100,101,102,103,105,106,``. A comma is needed to separate case IDs"
    ":hlm-p:`ats.aste.language`", "[recommended]", "Variant Language to be tested. Default is 'English'"
    
    
An example of setting up properties:
    
.. code-block:: xml
    
    <property name="ats.server" value="4fio00105"  />
    <property name="ats.drop.location" value="\\trwsimXX\ATS_TEST_SHARE\" />
    <property name="ats.aste.email.list" value="temp.user@company.com; another.email@company.com" />
    <property name="ats.flashfiles.minlimit" value="2" />
    <property name="ats.product.name" value="PRODUCT" />
    <property name="ats.aste.plan.name" value="plan" />
    <property name="ats.product.hwid" value="" />
    <property name="ats.test.timeout" value="60" />
    <property name="ats.aste.testrun.name" value="${r'$'}{build.id}_${r'$'}{ats.product.name}_${r'$'}{major.version}.${r'$'}{minor.version}" />
    <property name="ats.aste.testasset.location" value="" />
    <property name="ats.aste.software.release" value="SPP 51.32" />
    <property name="ats.aste.test.type" value="smoke" />
    <property name="ats.aste.testasset.caseids" value="100,101,102,104,106," />
    <property name="ats.aste.software.version" value="W810" />
    <property name="ats.aste.language" value="English" />
    

*PLEASE NOTE:* Always declare *Properties* before and *filesets* after importing helium.ant.xml.

**STEP 2: Call target ats-aste**

To execute the target, a property should be set(``<property name="enabled.aste" value="true" />``).

Then call :hlm-t:`ats-aste`, which will create the ATSDrop.zip (test package).

If property ``ats.aste.email.list`` is set, an email (test report) will be sent when the tests are ready on ATS/ASTE.


Skip Sending AtsDrop to ATS
---------------------------

click :ref:`Skip-Sending-AtsDrop-label`:


    
    