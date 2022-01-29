<Query Kind="Expression">
  <Output>DataGrids</Output>
  <NuGetReference>TIKSN-Framework</NuGetReference>
  <NuGetReference>UnicodeInformation</NuGetReference>
  <Namespace>System.Globalization</Namespace>
  <Namespace>System.Unicode</Namespace>
</Query>

Util.ReadLine()
.ToCharArray()
.Select(c => Tuple.Create(
	c,
	UnicodeInfo.GetName(c)
))