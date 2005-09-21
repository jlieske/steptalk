/**
    GSObjcRuntimeSupport

    Copyright (c) 2002 Free Software Foundation

    Written by: Stefan Kleine Stegemann <stefankst@gmail.com>
    Date: 2005 September 6
    License: LGPL

    This file is part of the StepTalk project.
*/

#import "ObjcRuntimeSupport.h"
#include <stdlib.h>

// -----------------------------------------------------------------------
// private functions

static BOOL MyIterateSelectors(Class clazz, VisitSelectorCallback callback, void* userData)
{
   if (!clazz || !callback)
      return NO;
   
   struct objc_method_list* methods = clazz->methods;
   while (methods != NULL) {
      int i;
      for (i = 0; i < methods->method_count; i++) {
         if (!callback(clazz, methods->method_list[i].method_name, userData))
            return NO;
      }
      methods = methods->method_next;
   }

   return YES;
}

// -----------------------------------------------------------------------
// public functions

void ObjcIterateClasses(VisitClassCallback callback, void* userData)
{
   if (!callback)
      return;
   
   void* state = 0;
   Class nextClass;
   while ((nextClass = objc_next_class(&state))) {
      if (!callback(nextClass, userData))
         break;
   }
}

void ObjcIterateSelectors(Class clazz, BOOL includeMeta, VisitSelectorCallback callback, void* userData)
{
   if (MyIterateSelectors(clazz, callback, userData) && includeMeta) {
      MyIterateSelectors(ObjcClassGetMeta(clazz), callback, userData);
   }
}

const char* ObjcClassName(Class class)
{
   return class_get_class_name(class);
}

Class ObjcClassGetMeta(Class class)
{
   return class_get_meta_class(class);
}

SEL ObjcRegisterSel(const char* name, const char* types)
{
   if (name == NULL)
      return NULL;
   
   if (types == NULL)
      return sel_register_name(name);
   
   return sel_register_typed_name(name, types);
}

const char* ObjcSelName(SEL selector)
{
   return sel_get_name(selector);
}

const char* ObjcSelGetType(SEL selector)
{
   return sel_get_type(selector);
}

int ObjcSizeOfType(const char* type)
{
   return objc_sizeof_type(type);
}

int ObjcAlignOfType(const char* type)
{
   return objc_alignof_type(type);
}

const char* ObjcSkipTypeSpec(const char* type)
{
   return objc_skip_typespec(type);
}

const char* ObjcSkipArgSpec(const char* type)
{
   return objc_skip_argspec(type);
}
