package com.crossecore.java

import com.crossecore.DependencyManager
import com.crossecore.IdentifierProvider
import com.crossecore.Utils
import java.util.ArrayList
import java.util.Collection
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EEnum
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.util.EcoreUtil
import com.crossecore.EcoreVisitor
import org.eclipse.emf.ecore.EEnumLiteral

class PackageImplGenerator extends EcoreVisitor{
	
	private IdentifierProvider id = new JavaIdentifier();
	//private CSharpLiteralIdentifier literalId = new CSharpLiteralIdentifier();
	
	new(){
		super();
	}
	
	new(String path, String filenamePattern, EPackage epackage){
		super(path, filenamePattern, epackage);

	}
	
	
	
	override caseEPackage(EPackage epackage){
	var sortedEClasses = new ArrayList<EClassifier>(DependencyManager.sortEClasses(epackage)); 
	
	var Collection<EClass> eclasses =  EcoreUtil.getObjectsByType(epackage.EClassifiers, EcorePackage.Literals.ECLASS);
	var Collection<EEnum> enums =  EcoreUtil.getObjectsByType(epackage.EClassifiers, EcorePackage.Literals.EENUM);
	var Collection<EDataType> edatatypes = EcoreUtil.getObjectsByType(epackage.EClassifiers, EcorePackage.Literals.EDATA_TYPE);
	sortedEClasses.addAll(edatatypes);
	
		'''
		package «epackage.name»;
		
		import org.eclipse.emf.ecore.*;
		
		public class «id.EPackagePackageImpl(epackage)» extends org.eclipse.emf.ecore.impl.EPackageImpl implements «id.EPackagePackage(epackage)»{
				public static String eNAME = "«epackage.name»";
				
				public static String eNS_URI = "«epackage.nsURI»";
				
				public static String eNS_PREFIX = "«epackage.nsPrefix»";
				
				public static «id.EPackagePackage(epackage)» eINSTANCE = init();
				
				private «id.EPackagePackageImpl(epackage)»()
				{
					super(eNS_URI, «id.EPackageFactoryImpl(epackage)».eINSTANCE);
				}
				
				private static boolean isInited = false;
				
				
				public static void unload(){
				
					«FOR e:eclasses»
						«id.doSwitch(e)».allInstances_.clear();
					«ENDFOR»
					
				}
				
				public static «id.EPackagePackage(epackage)» init()
				{
					
					unload();
					
					if (isInited) return («id.EPackagePackage(epackage)»)EPackage.Registry.INSTANCE.getEPackage(«id.EPackagePackageImpl(epackage)».eNS_URI);

					// Obtain or create and register package
					«id.EPackagePackageImpl(epackage)» thePackage = («id.EPackagePackageImpl(epackage)»)(EPackage.Registry.INSTANCE.get(eNS_URI) instanceof «id.EPackagePackageImpl(epackage)» ? EPackage.Registry.INSTANCE.get(eNS_URI) : new «id.EPackagePackageImpl(epackage)»());
		
					isInited = true;
		
					// Create package meta-data objects
					thePackage.createPackageContents();
		
					// Initialize created meta-data
					thePackage.initializePackageContents();
		
					// Register package validator
					EValidator.Registry.INSTANCE.put
						(thePackage, 
						 new EValidator.Descriptor() {
							 public EValidator getEValidator() {
								 return «id.doSwitch(epackage)»Validator.INSTANCE;
							 }
					 });
		
					// Mark meta-data to indicate it can't be changed
					thePackage.freeze();
		
					// Update the registry and return the package
					EPackage.Registry.INSTANCE.put(«id.EPackagePackageImpl(epackage)».eNS_URI, thePackage);
					return thePackage;
		        }
		        
		        private boolean isCreated = false;
	            public void createPackageContents()
	            {
	                if (isCreated) return;
	                isCreated = true;
					«FOR EClass eclass:eclasses»
						«id.EClassEClass(eclass)» = createEClass(«id.literal(eclass)»);
						«FOR EStructuralFeature feature:eclass.EStructuralFeatures»
							«IF feature instanceof EReference»
							createEReference(«id.EClassEClass(eclass)», «id.literal(feature)»);
							«ELSEIF feature instanceof EAttribute»
							createEAttribute(«id.EClassEClass(eclass)», «id.literal(feature)»);
							«ENDIF»
						«ENDFOR»
					«ENDFOR»
					
					«FOR EEnum eenum:enums»
						«id.EEnumEEnum(eenum)» = createEEnum(«id.literal(eenum)»);
					«ENDFOR»
		        }
		        
		        private boolean isInitialized = false;
		        public void initializePackageContents()
		        {
	                if (isInitialized) return;
	                isInitialized = true;
		            // Initialize package
					setName(eNAME);
					setNsPrefix(eNS_PREFIX);
					setNsURI(eNS_URI);
		
					«FOR EClass e:eclasses»
						
						«FOR EClass super_:e.ESuperTypes»
							«id.EClassEClass(e)».getESuperTypes().add(«id.getEClass(super_)»());
														
						«ENDFOR»
					«ENDFOR»
					
					«FOR EClass e:eclasses»
						initEClass(«id.EClassEClass(e)», «id.doSwitch(e)».class, "«e.name»", «IF !e.abstract»!«ENDIF»IS_ABSTRACT, «IF !e.interface»!«ENDIF»IS_INTERFACE, IS_GENERATED_INSTANCE_CLASS);						
						
						«FOR EAttribute a:e.EAttributes»
						initEAttribute(«id.getEAttribute(a)»(), 
							«IF Utils.isEcoreEPackage(a.EType.EPackage)»ecorePackage.«id.getEClassifier(a.EType)»()«ELSE»this.«id.getEClassifier(a.EType)»()«ENDIF», 
							"«a.name»", 
							«IF a.defaultValue===null»null«ELSE»"«a.defaultValue»"«ENDIF», 
							«a.lowerBound», 
							«a.upperBound», 
							EAttribute.class, 
							«IF !a.transient»!«ENDIF»IS_TRANSIENT, 
							«IF !a.volatile»!«ENDIF»IS_VOLATILE, 
							«IF !a.changeable»!«ENDIF»IS_CHANGEABLE, 
							«IF !a.unsettable»!«ENDIF»IS_UNSETTABLE, 
							«IF !a.isID»!«ENDIF»IS_ID, 
							«IF !a.unique»!«ENDIF»IS_UNIQUE, 
							«IF !a.derived»!«ENDIF»IS_DERIVED, 
							«IF !a.ordered»!«ENDIF»IS_ORDERED);
						«ENDFOR»
						
						«FOR EReference a:e.EReferences»
						initEReference(
							«id.getEReference(a)»(), 
							«IF Utils.isEcoreEPackage(a.EType.EPackage)»ecorePackage.«id.getEClassifier(a.EType)»()«ELSE»this.«id.getEClassifier(a.EType)»()«ENDIF», 
							«IF a.EOpposite!==null»«id.getEReference(a.EOpposite)»()«ELSE»null«ENDIF», 
							"«a.name»", 
							«IF a.defaultValue !== null»«a.defaultValue»«ELSE»null«ENDIF», 
							«a.lowerBound», 
							«a.upperBound», 
							«e.name».class, 
							«IF !a.transient»!«ENDIF»IS_TRANSIENT, 
							«IF !a.volatile»!«ENDIF»IS_VOLATILE, 
							«IF !a.changeable»!«ENDIF»IS_CHANGEABLE, 
							«IF !a.containment»!«ENDIF»IS_COMPOSITE, 
							«IF !a.resolveProxies»!«ENDIF»IS_RESOLVE_PROXIES, 
							«IF !a.unsettable»!«ENDIF»IS_UNSETTABLE, 
							«IF !a.unique»!«ENDIF»IS_UNIQUE, 
							«IF !a.derived»!«ENDIF»IS_DERIVED, 
							«IF !a.ordered»!«ENDIF»IS_ORDERED);
						«ENDFOR»
						
						
						
					«ENDFOR»
					
					«FOR EEnum e:enums»
					initEEnum(«id.EEnumEEnum(e)», «id.doSwitch(e)».class, "«e.name»");
					«FOR EEnumLiteral literal:e.ELiterals»
					addEEnumLiteral(«id.EEnumEEnum(e)», «id.doSwitch(e)».«literal.name.toUpperCase»);
					«ENDFOR»
					«ENDFOR»
					
					// Create resource
					createResource(eNS_URI);
		        }
		        
				
				«FOR EClass eclass:eclasses»
					private EClass «id.EClassEClass(eclass)» = null;
				«ENDFOR»
				
				
				«FOR EEnum eenum:enums»
					private EEnum «id.EEnumEEnum(eenum)» = null;
				«ENDFOR»
				
				«FOR EDataType edatatype:edatatypes»
					private EDataType «id.EDataTypeEDataType(edatatype)» = null;
				«ENDFOR»
				
				
				«FOR EClassifier eclassifier: sortedEClasses»
					«metaobjectid.doSwitch(eclassifier)»
				«ENDFOR»
				
				
				«FOR EClassifier eclassifier: sortedEClasses»
					«doSwitch(eclassifier)»
				«ENDFOR»
				
				public static class Literals{
					«FOR EClassifier eclassifier: sortedEClasses»
						«literals.doSwitch(eclassifier)»
					«ENDFOR»
				}
		 
		}
		
		'''
	
	}
	
	var metaobjectid = new EcoreVisitor(){
		

		
		override caseEEnum(EEnum enumeration){
			'''
			public final static int «id.literal(enumeration)» = «enumeration.classifierID»;
			'''
			
		}
		
		override caseEDataType(EDataType edatatype){
			'''
			public final static int «id.literal(edatatype)» = «edatatype.classifierID»;
			'''
		}
		
		override caseEClass(EClass eclassifier){

			var i = 0;

			'''
			public final static int «id.literal(eclassifier)» = «eclassifier.classifierID»;
			public final static int «id.EClassifier_FEATURE_COUNT(eclassifier)» = «FOR EClass _super:eclassifier.ESuperTypes SEPARATOR ' + '  AFTER ' + '»«id.EClassifier_FEATURE_COUNT(_super)»«ENDFOR»«eclassifier.EStructuralFeatures.size»;
			public final static int «id.EClassifier_OPERATION_COUNT(eclassifier)» = «FOR EClass _super:eclassifier.ESuperTypes SEPARATOR ' + '  AFTER ' + '»«id.EClassifier_OPERATION_COUNT(_super)»«ENDFOR»«eclassifier.EOperations.size»;
			
			«FOR EStructuralFeature feature:eclassifier.EAllStructuralFeatures»
				public final static int «id.literal(eclassifier,feature)» = «i++»;
			«ENDFOR»
			
			'''
		
		}
		
		
		
	}
	
	val literals = new EcoreVisitor() {
		
		override caseEClass(EClass eclass){
			'''
			public final static EClass «id.literal(eclass)» = «id.EPackagePackageImpl(eclass.EPackage)».eINSTANCE.«id.getEClass(eclass)»();
			
			«FOR EReference ereference:eclass.EReferences»
				«doSwitch(ereference)»
			«ENDFOR»
			
			«FOR EAttribute eattribute:eclass.EAttributes»
				«doSwitch(eattribute)»
			«ENDFOR»
			'''
		}
		
		override caseEEnum(EEnum enumeration){
			'''
			public final static EEnum «id.literal(enumeration)» = «id.EPackagePackageImpl(enumeration.EPackage)».eINSTANCE.«id.getEEnum(enumeration)»();
			'''
		}
		
		override caseEDataType(EDataType edatatype){
			'''
			public final static EDataType «id.literal(edatatype)» = «id.EPackagePackageImpl(edatatype.EPackage)».eINSTANCE.«id.getEDataType(edatatype)»();
			'''
		}
	
		override caseEReference(EReference ereference){
			'''
			public final static EReference «id.literal(ereference)» = «id.EPackagePackageImpl(ereference.EContainingClass.EPackage)».eINSTANCE.«id.getEReference(ereference)»();
			'''
		}
		
		override caseEAttribute(EAttribute eattribute){
			'''
			public final static EAttribute «id.literal(eattribute)» = «id.EPackagePackageImpl(eattribute.EContainingClass.EPackage)».eINSTANCE.«id.getEAttribute(eattribute)»();
			'''
		}
		
	
	};
	
	override caseEDataType(EDataType edatatype){
		'''
		public EDataType «id.getEDataType(edatatype)»(){return «id.EDataTypeEDataType(edatatype)»;}
		'''
		
	}
	
	override caseEEnum(EEnum enumeration){
		'''
		public EEnum «id.getEEnum(enumeration)»(){return «id.EEnumEEnum(enumeration)»;}
		'''
		
	}
	
	override caseEClass(EClass eclass){
		var featureIdx = 0;
		'''
		public EClass «id.getEClass(eclass)»(){return «id.EClassEClass(eclass)»;}
		
		«FOR EStructuralFeature feature:eclass.EStructuralFeatures»
			«IF feature instanceof EAttribute»
			public EAttribute «id.getEAttribute(feature as EAttribute)»(){return (EAttribute)«id.EClassEClass(feature.EContainingClass)».getEStructuralFeatures().get(«featureIdx++»);}
			«ELSEIF feature instanceof EReference»
			public EReference «id.getEReference(feature as EReference)»(){return (EReference)«id.EClassEClass(feature.EContainingClass)».getEStructuralFeatures().get(«featureIdx++»);}
			«ENDIF»
		«ENDFOR»
		'''
	}
	
	
}