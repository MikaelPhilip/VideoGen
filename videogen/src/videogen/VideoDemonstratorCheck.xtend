package videogen

import java.util.HashMap
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.junit.Test
import org.xtext.example.mydsl.VideoGenStandaloneSetupGenerated
import org.xtext.example.mydsl.videoGen.AlternativeVideoSeq
import org.xtext.example.mydsl.videoGen.MandatoryVideoSeq
import org.xtext.example.mydsl.videoGen.OptionalVideoSeq
import org.xtext.example.mydsl.videoGen.VideoGeneratorModel
import static org.junit.Assert.*
import java.util.Random
import java.util.ArrayList

/**
 * Class pour v�rifier la validit�e d'un model en le parcourant
 */
class VideoDemonstratorCheck {
	
	def loadVideoGenerator(URI uri) {
		new VideoGenStandaloneSetupGenerated().createInjectorAndDoEMFRegistration()
		var res = new ResourceSetImpl().getResource(uri, true);
		res.contents.get(0) as VideoGeneratorModel
	}
	
	def saveVideoGenerator(URI uri, VideoGeneratorModel pollS) {
		var Resource rs = new ResourceSetImpl().createResource(uri); 
		rs.getContents.add(pollS); 
		rs.save(new HashMap());
	}
	
	@Test
	def test1() {
		// loading
		var videoGen = loadVideoGenerator(URI.createURI("fooReal.videogen")) 
		assertNotNull(videoGen)	
		// MODEL MANAGEMENT (ANALYSIS, TRANSFORMATION)
		videoGen.videoseqs.forEach[videoseq | 
			if (videoseq instanceof MandatoryVideoSeq) {
				val desc = (videoseq as MandatoryVideoSeq).description
				if(desc.videoid.isNullOrEmpty)  desc.videoid = genID() 				
			}
			else if (videoseq instanceof OptionalVideoSeq) {
				val desc = (videoseq as OptionalVideoSeq).description
				if(desc.videoid.isNullOrEmpty) desc.videoid = genID() 
			}
			else {
				val altvid = (videoseq as AlternativeVideoSeq)
				if(altvid.videoid.isNullOrEmpty) altvid.videoid = genID()
				for (vdesc : altvid.videodescs) {
					if(vdesc.videoid.isNullOrEmpty) vdesc.videoid = genID()
				}
			}
		]
	// serializing
	saveVideoGenerator(URI.createURI("fooRealOut.xmi"), videoGen)
	saveVideoGenerator(URI.createURI("fooRealOut.videogen"), videoGen)		
		
	check(videoGen) //Appel m�thode pour v�rifier le model
		 	
	}
	
	//M�thode pour v�rifier le model en le parcourant, renvoit des warning en cas de pb
	def void check(VideoGeneratorModel videoGen) {
		val listIdUse = new ArrayList<String>();
		println("#Sequence FFmpeg generate")
		videoGen.videoseqs.forEach[videoseq | 
			if (videoseq instanceof MandatoryVideoSeq) {
				val desc = (videoseq as MandatoryVideoSeq).description
				if(!desc.videoid.isNullOrEmpty && !desc.location.isNullOrEmpty)  
					println ("file '" + desc.location + "'")  		
					listIdUse.add(desc.videoid);	
			}
			else if (videoseq instanceof OptionalVideoSeq) {
				val desc = (videoseq as OptionalVideoSeq).description
				if(!desc.videoid.isNullOrEmpty && !desc.location.isNullOrEmpty) {
					val test = new Random().nextInt(100) //Generer un nombre entre 0 et 100
					if(test>100 || test<0){
						println("WARNING: le resultat de test est incoh�rent: vid�o ignor�e")
					}else{
						println("#TestRes:" + test)
						if(test <= 50){
							println ("file '" + desc.location + "'")
							listIdUse.add(desc.videoid);
						}
					} 	 	
				}
			}
			else {
				val altvid = (videoseq as AlternativeVideoSeq)
				//On r�cupere la taille de la liste et on genere un entier al�atoire pour chosir la video 
				val choix = new Random().nextInt(altvid.videodescs.size)
				println("#Choix:" + choix)
				if(choix>altvid.videodescs.size || choix<0){
					System.out.println("WARNING: le resultat de test est incoh�rent: vid�o ignor�e")
				}else{
					val vdesc = altvid.videodescs.get(choix)	 
					if(!vdesc.videoid.isNullOrEmpty && !vdesc.location.isNullOrEmpty) {
						println ("file '" + vdesc.location + "'") 
						listIdUse.add(vdesc.videoid);
					}
				}
			}
		]
		println("#End of generation")
	}
	
	static var i = 0;
	def genID() {
		"v" + i++
	}
	
}