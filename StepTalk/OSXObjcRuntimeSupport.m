/**
    OSXObjcRuntimeSupport

    Copyright (c) 2002 Free Software Foundation

    Written by: Stefan Kleine Stegemann <stefankst@gmail.com>
    Date: 2005 September 6
    License: LGPL

    This file is part of the StepTalk project.
*/

/*
 * For an in-depth discussion and reference of the OSX Objective-C
 * runtime system see:
 * http://developer.apple.com/documentation/Cocoa/Reference/ObjCRuntimeRef/
 */

#import "ObjcRuntimeSupport.h"
#include <stdlib.h>

// ---------------------------------------------------------------------
//  private functions

static int MyObjcSizeOfType(const char* type, int* align);

static BOOL MyIsNSObjectDescendant(Class clazz)
{
   Class superclass = clazz;
   while ((superclass != NULL) && (superclass != [NSObject class]))
      superclass = superclass->super_class;
   return superclass != NULL;
}

static BOOL MyIsClassExcluded(Class clazz)
{
   // NSATSGlyphGenerator lurks around but is deprecated
   // (we get a runtime warning if we access the class)
   if (strcmp(clazz->name, "NSATSGlyphGenerator") == 0)
      return YES;
   
   return NO;
}

static BOOL MyIterateSelectors(Class clazz, VisitSelectorCallback callback, void* userData)
{
   if (!clazz || !callback)
      return NO;
   
   void *iterator = 0;
   struct objc_method_list* methodList = class_nextMethodList(clazz, &iterator);
   while(methodList != NULL)
   {
      int i;
      for (i = 0; i < methodList->method_count; i++) {
         if (!callback(clazz, methodList->method_list[i].method_name, userData))
            return NO;
      }
      methodList = class_nextMethodList(clazz, &iterator);
   }
   
   return YES;
}

int MyObjcSizeOfArray(const char* type, int* align)
{
   if (!type || *type != _C_ARY_B) {
      NSLog(@"MyObjcSizeOfArray Fatal: not an array");
      return -1;
   }

   // element count
   type++;
   char elementCountStr[21];
   int  elementCountIndex = 0;
   while ((*type >= '0') && (*type <= '9') && (elementCountIndex < 20))
      elementCountStr[elementCountIndex++] = *(type++);

   if (elementCountIndex >= 20) {
      NSLog(@"array size too long!");
      return -1;
   } 
   elementCountStr[elementCountIndex] = '\0';

   int size = atoi(elementCountStr) * MyObjcSizeOfType(type, align);

   return size;
}

int MyObjcSizeOfStruct(const char* type, int* align)
{
   if (!type || *type != _C_STRUCT_B) {
      NSLog(@"MyObjcSizeOfStruct Fatal: not a struct");
      return -1;
   }

   // skip struct name and '='
   type++;
   while ((*type != '\0') && (*type != '='))
      type++;

   if (*type != '=') {
      NSLog(@"MyObjcSizeOfStruct Fatal: invalid struct (missing =)");
      return -1;
   }
   type++;

   int size = 0;
   int structAlign = 0;
   while (*type != '\0' && *type != _C_STRUCT_E) {
      int possibleAlign = 0;
      size += MyObjcSizeOfType(type, &possibleAlign);
      if (possibleAlign > structAlign)
         structAlign = possibleAlign;
      
      if (size % possibleAlign)
         size = possibleAlign * ((size + possibleAlign - 1) / possibleAlign);
      
      type = ObjcSkipTypeSpec(type);
      if (type == NULL) {
         NSLog(@"MyObjcSizeOfStruct Fatal: skip type failed");
         return -1;
      }
   }
   
   size = structAlign * ((size + structAlign - 1) / structAlign);
   
   *align = structAlign;
   return size;
}

int MyObjcSizeOfUnion(const char* type, int* align)
{
   if (!type || *type != _C_UNION_B) {
      NSLog(@"MyObjcSizeOfUnion Fatal: not a union");
      return -1;
   }
   
   // skip union name and '='
   type++;
   while ((*type != '\0') && (*type != '='))
      type++;
   
   if (*type != '=') {
      NSLog(@"MyObjcSizeOfUnion Fatal: invalid union (missing =)");
      return -1;
   }
   type++;
   
   int size = 0;
   int unionAlign = 0;
   while (*type != '\0' && *type != _C_UNION_E) {
      int elementAlign = 0;
      int elementSize = MyObjcSizeOfType(type, &elementAlign);
      if (elementAlign > unionAlign)
         unionAlign = elementAlign;

      type = ObjcSkipTypeSpec(type);
      if (type == NULL) {
         NSLog(@"MyObjcSizeOfUnion Fatal: skip type failed");
         return -1;
      }
      if (elementSize > size)
         size = elementSize;
   }
   
   *align = unionAlign;
   return size;
}

int MyObjcSizeOfType(const char* type, int* align)
{
   if (!type || !align)
      return -1;
   
   *align = -1;
   
   switch (*type) {
      case _C_FLT: {
         *align = __alignof__(float);
         return sizeof(float);
      }
      case _C_DBL: {
         *align = __alignof__(double);
         return sizeof(double);
      }
      case _C_INT: {
         *align = __alignof__(int);
         return sizeof(int);
      }
      case _C_UINT: {
         *align = __alignof__(unsigned int);
         return sizeof(unsigned int);
      }
      case _C_LNG: {
         *align = __alignof__(long);
         return sizeof(long);
      }
      case _C_ULNG: {
         *align = __alignof__(unsigned long);
         return sizeof(unsigned long);
      }
      case _C_LNG_LNG: {
         *align = __alignof__(long long);
         return sizeof(long long);
      }
      case _C_ULNG_LNG: {
         *align = __alignof__(unsigned long long);
         return sizeof(unsigned long long);
      }
      case _C_SHT: {
         *align = __alignof__(short);
         return sizeof(short);
      }
      case _C_USHT: {
         *align = __alignof__(unsigned short);
         return sizeof(unsigned short);
      }
      case _C_CHR: {
         *align = __alignof__(char);
         return sizeof(char);
      }
      case _C_UCHR: {
         *align = __alignof__(unsigned char);
         return sizeof(unsigned char);
      }
      case _C_VOID: {
         *align = __alignof__(void);
         return sizeof(void);
      }
      case _C_ID: {
         *align = __alignof__(id);
         return sizeof(id);
      }
      case _C_CLASS: {
         *align = __alignof__(Class);
         return sizeof(Class);
      }
      case _C_SEL: {
         *align = __alignof__(SEL);
         return sizeof(SEL);
      }
      case _C_CHARPTR: {
         *align = __alignof__(char*);
         return sizeof(char*);
      }
      case _C_PTR: {
         *align = __alignof__(void*);
         return sizeof(void*); // pointers are all same size
      }
      case _C_ARY_B: {
         return MyObjcSizeOfArray(type, align);
      }
      case _C_STRUCT_B: {
         return MyObjcSizeOfStruct(type, align);
      }
      case _C_UNION_B: {
         return MyObjcSizeOfUnion(type, align);
      }
         
      case _C_CONST:
      case _C_IN:
      case _C_INOUT:
      case _C_OUT:
      case _C_BYCOPY:
      case _C_ONEWAY: return MyObjcSizeOfType(++type, align);
   }
   
   NSLog(@"ObjcSizeOfType Error: unknown type: %c", *type);
   return -1;
}

static const char* MyObjcSkipArray(const char* type)
{
   if (!type || *type != _C_ARY_B) {
      NSLog(@"MyObjcSkipArray Fatal: not an array");
      return NULL;
   }
   
   // length
   type++;
   while ((*type >= '0') && (*type <= '9'))
      type++;
   
   type = ObjcSkipTypeSpec(type);
   if (*type != _C_ARY_E) {
      NSLog(@"MyObjcSkipArray Fatal: unterminated array");
      return NULL;
   }
   
   return ++type;
}

static const char* MyObjcSkipComplexType(const char* type, const char beginChar, const char termChar)
{
   if (!type || *type != beginChar) {
      NSLog(@"MyObjcSkipStruct Fatal: expect %c", beginChar);
      return NULL;
   }
   
   type++;
   int level = 1;
   while ((*type != '\0') && (level > 0)) {
      if (*type == beginChar) level++;
      else if (*type == termChar) level--;
      *type++;
   }
   
   if (level > 0) {
      NSLog(@"MyObjcSkipStruct Fatal: unterminated complex type (missing %c)", termChar);
      return NULL;
   }
   
   return type;
}

static const char* MyObjcSkipOffset(const char* type)
{
   // this works like gcc3 objclib. dunno whether this applies
   // to OSX as well but it shouldn't do any harm   
   if (*type == '+')
      type++;
   while (isdigit(*(++type)));
   return type;
}

// ---------------------------------------------------------------------
//  public functions

void ObjcIterateClasses(VisitClassCallback callback, void* userData)
{
   if (!callback)
      return;
   
   int numClasses = objc_getClassList(NULL, 0);
   if (numClasses == 0)
      return;

   Class* classes = (Class*)malloc(sizeof(Class) * numClasses);
   objc_getClassList(classes, numClasses);
   
   int i;
   for (i = 0; i < numClasses; i++)
   {
      Class nextClass = classes[i];
      if (MyIsClassExcluded(nextClass) || !MyIsNSObjectDescendant(nextClass))
         continue;

      if (!callback(nextClass, userData))
         break;
   }

   free(classes);
}

void ObjcIterateSelectors(Class clazz, BOOL includeMeta, VisitSelectorCallback callback, void* userData)
{
   if (MyIterateSelectors(clazz, callback, userData) && includeMeta) {
      MyIterateSelectors(ObjcClassGetMeta(clazz), callback, userData);
   }
}

const char* ObjcClassName(Class class)
{
   return class->name;
}

Class ObjcClassGetMeta(Class class)
{
   return class->isa;
}

SEL ObjcRegisterSel(const char* name, const char* types)
{
   if (!name)
      return NULL;
   
   return sel_registerName(name);
}

const char* ObjcSelName(SEL selector)
{
   return sel_getName(selector);
}

const char* ObjcSelGetType(SEL selector)
{
   return NULL;
}

int ObjcSizeOfType(const char* type)
{
   int align = -1;
   return MyObjcSizeOfType(type, &align);
}

int ObjcAlignOfType(const char* type)
{
   int align = -1;
   if (MyObjcSizeOfType(type, &align) == -1) {
      return -1;
   }
   return align;
}

const char* ObjcSkipTypeSpec(const char* type)
{
   if (!type)
      return NULL;

   switch (*type) {
      case _C_FLT:
      case _C_DBL:
      case _C_INT:
      case _C_UINT:
      case _C_LNG:
      case _C_ULNG:
      case _C_LNG_LNG:
      case _C_ULNG_LNG:
      case _C_SHT:
      case _C_USHT:
      case _C_CHR:
      case _C_UCHR:
      case _C_VOID:
      case _C_ID:
      case _C_CLASS:
      case _C_SEL:
      case _C_CHARPTR: return ++type;
      case _C_PTR: return ObjcSkipTypeSpec(++type);
      case _C_ARY_B: return MyObjcSkipArray(type);
      case _C_STRUCT_B: return MyObjcSkipComplexType(type, _C_STRUCT_B, _C_STRUCT_E);
      case _C_UNION_B: return MyObjcSkipComplexType(type, _C_UNION_B, _C_UNION_E);

      case _C_CONST:
      case _C_IN:
      case _C_INOUT:
      case _C_OUT:
      case _C_BYCOPY:
      case _C_ONEWAY: return ObjcSkipTypeSpec(++type);
   }
 
   NSLog(@"ObjcSkipType Error: unkown type: %c", *type);
   return NULL;
}

const char* ObjcSkipArgSpec(const char* type)
{
   type = ObjcSkipTypeSpec(type);
   type = MyObjcSkipOffset(type);
   return type;
}
