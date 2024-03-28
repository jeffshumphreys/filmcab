$ScriptNameWithoutExtension = '_start_new_batch_run_session' 
$t = Get-ScheduledTask -TaskName $ScriptNameWithoutExtension|select Triggers|Select  @{Name='TriggerClass'; Expression = { 
    (@($_.Triggers)[0])
    $t.TriggerClass.pstypenames[0] # Microsoft.Management.Infrastructure.CimInstance#Root/Microsoft/Windows/TaskScheduler/MSFT_TaskDailyTrigger

}      
}

<#
$t.TriggerClass.GetType()|Select *


Module                     : Microsoft.Management.Infrastructure.dll
Assembly                   : Microsoft.Management.Infrastructure, Version=1.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35
TypeHandle                 : System.RuntimeTypeHandle
DeclaringMethod            : 
BaseType                   : System.Object
UnderlyingSystemType       : Microsoft.Management.Infrastructure.CimInstance
FullName                   : Microsoft.Management.Infrastructure.CimInstance
AssemblyQualifiedName      : Microsoft.Management.Infrastructure.CimInstance, Microsoft.Management.Infrastructure, Version=1.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35
Namespace                  : Microsoft.Management.Infrastructure
GUID                       : f541201b-2bc6-342c-bee1-935bb88975cc
IsEnum                     : False
GenericParameterAttributes : 
IsSecurityCritical         : True
IsSecuritySafeCritical     : False
IsSecurityTransparent      : False
IsGenericTypeDefinition    : False
IsGenericParameter         : False
GenericParameterPosition   : 
IsGenericType              : False
IsConstructedGenericType   : False
ContainsGenericParameters  : False
StructLayoutAttribute      : System.Runtime.InteropServices.StructLayoutAttribute
Name                       : CimInstance
MemberType                 : TypeInfo
DeclaringType              : 
ReflectedType              : 
MetadataToken              : 33554439
GenericTypeParameters      : {}
DeclaredConstructors       : {Void .ctor(Microsoft.Management.Infrastructure.Native.InstanceHandle, Microsoft.Management.Infrastructure.Internal.SharedInstanceHandle), Void .ctor(Microsoft.Management.Infrastructure.CimInstance), Void .ctor(System.String), Void .ctor(System.String, System.String)...}
DeclaredEvents             : {}
DeclaredFields             : {_myHandle, _systemProperties, _disposed, _CimSessionInstanceID...}
DeclaredMembers            : {Microsoft.Management.Infrastructure.Native.InstanceHandle get_InstanceHandle(), Microsoft.Management.Infrastructure.Generic.CimKeyedCollection`1[Microsoft.Management.Infrastructure.CimProperty] get_CimInstanceProperties(), System.String GetCimSystemPath(Microsoft.Management.Infrastructure.CimSystemProperties, 
                             System.Collections.IEnumerator), System.Object ConvertToNativeLayer(System.Object)...}
DeclaredMethods            : {Microsoft.Management.Infrastructure.Native.InstanceHandle get_InstanceHandle(), Microsoft.Management.Infrastructure.Generic.CimKeyedCollection`1[Microsoft.Management.Infrastructure.CimProperty] get_CimInstanceProperties(), System.String GetCimSystemPath(Microsoft.Management.Infrastructure.CimSystemProperties, 
                             System.Collections.IEnumerator), System.Object ConvertToNativeLayer(System.Object)...}
DeclaredNestedTypes        : {Microsoft.Management.Infrastructure.CimInstance+<>c}
DeclaredProperties         : {Microsoft.Management.Infrastructure.Native.InstanceHandle InstanceHandle, Microsoft.Management.Infrastructure.CimClass CimClass, Microsoft.Management.Infrastructure.Generic.CimKeyedCollection`1[Microsoft.Management.Infrastructure.CimProperty] CimInstanceProperties, 
                             Microsoft.Management.Infrastructure.CimSystemProperties CimSystemProperties}
ImplementedInterfaces      : {System.IDisposable, System.ICloneable, System.Runtime.Serialization.ISerializable}
TypeInitializer            : Void .cctor()
IsNested                   : False
Attributes                 : AutoLayout, AnsiClass, Class, Public, Sealed, Serializable, BeforeFieldInit
IsVisible                  : True
IsNotPublic                : False
IsPublic                   : True
IsNestedPublic             : False
IsNestedPrivate            : False
IsNestedFamily             : False
IsNestedAssembly           : False
IsNestedFamANDAssem        : False
IsNestedFamORAssem         : False
IsAutoLayout               : True
IsLayoutSequential         : False
IsExplicitLayout           : False
IsClass                    : True
IsInterface                : False
IsValueType                : False
IsAbstract                 : False
IsSealed                   : True
IsSpecialName              : False
IsImport                   : False
IsSerializable             : True
IsAnsiClass                : True
IsUnicodeClass             : False
IsAutoClass                : False
IsArray                    : False
IsByRef                    : False
IsPointer                  : False
IsPrimitive                : False
IsCOMObject                : False
HasElementType             : False
IsContextful               : False
IsMarshalByRef             : False
GenericTypeArguments       : {}
CustomAttributes           : {[System.SerializableAttribute()]}

pstypenames               CodeProperty System.Collections.ObjectModel.Collection`1[[System.String, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]] pstypenames{get=PSTypeNames;}                                                                                                                                            
psadapted                 MemberSet    psadapted {Enabled, EndBoundary, ExecutionTimeLimit, Id, Repetition, StartBoundary, DaysInterval, RandomDelay, PSComputerName, get_CimInstanceProperties, Dispose, GetCimSessionInstanceId, GetCimSessionComputerName, get_CimClass, get_CimSystemProperties, GetObjectData, ToString, Equals, GetHashCode, GetT...
psbase                    MemberSet    psbase {CimClass, CimInstanceProperties, CimSystemProperties, get_CimInstanceProperties, Dispose, GetCimSessionInstanceId, GetCimSessionComputerName, get_CimClass, get_CimSystemProperties, GetObjectData, ToString, Equals, GetHashCode, GetType, Clone}                                                         
psextended                MemberSet    psextended {}                                                                                                                                                                                                                                                                                                      
psobject                  MemberSet    psobject {BaseObject, Members, Properties, Methods, ImmediateBaseObject, TypeNames, get_BaseObject, ToString, get_Members, get_Properties, get_Methods, get_ImmediateBaseObject, Copy, Equals, GetHashCode, get_TypeNames, CompareTo, GetObjectData, GetType, GetMetaObject}                                       
Clone                     Method       System.Object ICloneable.Clone()                                                                                                                                                                                                                                                                                   
Dispose                   Method       void Dispose(), void IDisposable.Dispose()                                                                                                                                                                                                                                                                         
Equals                    Method       bool Equals(System.Object obj)                                                                                                                                                                                                                                                                                     
GetCimSessionComputerName Method       string GetCimSessionComputerName()                                                                                                                                                                                                                                                                                 
GetCimSessionInstanceId   Method       guid GetCimSessionInstanceId()                                                                                                                                                                                                                                                                                     
GetHashCode               Method       int GetHashCode()                                                                                                                                                                                                                                                                                                  
GetObjectData             Method       void GetObjectData(System.Runtime.Serialization.SerializationInfo info, System.Runtime.Serialization.StreamingContext context), void ISerializable.GetObjectData(System.Runtime.Serialization.SerializationInfo info, System.Runtime.Serialization.StreamingContext context)                                       
GetType                   Method       type GetType()                                                                                                                                                                                                                                                                                                     
get_CimClass              Method       cimclass get_CimClass()                                                                                                                                                                                                                                                                                            
get_CimInstanceProperties Method       Microsoft.Management.Infrastructure.Generic.CimKeyedCollection[Microsoft.Management.Infrastructure.CimProperty] get_CimInstanceProperties()                                                                                                                                                                        
get_CimSystemProperties   Method       Microsoft.Management.Infrastructure.CimSystemProperties get_CimSystemProperties()                                                                                                                                                                                                                                  
ToString                  Method       string ToString()                                                                                                                                                                                                                                                                                                  
DaysInterval              Property     int16 DaysInterval {get;set;}                                                                                                                                                                                                                                                                                      
Enabled                   Property     bool Enabled {get;set;}                                                                                                                                                                                                                                                                                            
EndBoundary               Property     string EndBoundary {get;set;}                                                                                                                                                                                                                                                                                      
ExecutionTimeLimit        Property     string ExecutionTimeLimit {get;set;}                                                                                                                                                                                                                                                                               
Id                        Property     string Id {get;set;}                                                                                                                                                                                                                                                                                               
PSComputerName            Property     string PSComputerName {get;}                                                                                                                                                                                                                                                                                       
RandomDelay               Property     string RandomDelay {get;set;}                                                                                                                                                                                                                                                                                      
Repetition                Property     CimInstance#Instance Repetition {get;set;}                                                                                                                                                                                                                                                                         
StartBoundary             Property     string StartBoundary {get;set;}         

#>