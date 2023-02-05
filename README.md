---
layout: post
title: RANSAC Algoritması ile Doğru Uyumlama
slug: ransac-algorithm
author: Bahri ABACI
categories:
- Makine Öğrenmesi
- Nümerik Yöntemler
- Veri Analizi
references: "Random sample consensus: a paradigm for model fitting with applications to image analysis and automated cartography"
thumbnail: /assets/post_resources/ransac_algorithm/thumbnail.svg
---
RANSAC (Random Sample and Consensus); gürültülü veriler üzerinde makine öğrenmesi ve veri analizi algoritmalarının gürbüz şekilde çalışabilmesi için kullanılan bir yöntemdir. Yöntem ilk olarak 1981 yılında Fischler ve Bolles tarafından konum belirleme problemlerinde karşılaşılan gürültülü (noisy) ve aykırı (outlier) veri sorununu ortadan kaldırmak için önerilmiştir. Bugüne kadar 24 binin üzerinde atıf alan yöntem, aykırı veri tespiti veya gürültüden bağımsız model uyumlama problemlerinde akla gelen ilk yöntemdir. Bu yazımızda RANSAC algoritmasının çalışma mantığından bahsettikten sonra, basit bir doğru uyumlama probleminde ne şekilde bir katkı sağladığı incelenecektir.

<!--more-->

Önceki yazılarımızda incelediğimiz makine öğrenmesi ve veri analizi yöntemlerinde veri üzerinden nümerik yöntemler ile sonuca ulaşmaya çalışmıştık. Bu yöntemlerde, verinin gürültülü olması durumu da göz önünde bulundurarak, tanımlanan hata fonksiyonlarını sıfıra eşitlemeye değil ortalama karesel hata ölçütünde en küçüklemeye çalışmıştık. Elde ettiğimiz yöntemler gerçek hayatta karşılaştığımız pek çok gürültü tipi için (normal, düzgün dağılımlı gürültü) istenilen sonuçları üretse de mühendislik problemlerinde karşılaşılan aykırı (outlier) tipte gürültüler için yeterli gürbüzlüğü sağlayamamaktadır. Bu yazımızın konusu olan RANSAC yöntemi aykırı tipte gürültülü veri içeren bir veri setinde önceki yazılarımızda incelediğimiz makine öğrenmesi ve veri analizi yöntemlerinin karalılığını artıran bir yöntemdir.

Yöntemin detaylarına geçmeden önce basit bir doğru uyumlama problemini daha önceki yazılarda yaptığımız şekilde çözmeye çalışalım.

Elimizde $(x_i,y_i)$ şeklinde verilen $N$ tane nokta olduğunu varsayalım. Doğru uyumlamada amaç, bu nokta çiftlerine $y_i = m x_i + b$ şeklinde bir doğru ile en küçük hata ile uyum sağlayan $(m,b)$ parametreleri ile ifade edilen doğruyu bulmaktır. Problem, karesel hata fonksiyonunun en küçüklemesi şeklinde düşünülürse aşağıdaki hata denklemi yazılabilir.

$$E(m,b) = \frac{1}{2}\sum_{i=1}^{N} \left( y_i - m x_i - b \right)^2$$

[Gradyan İniş Yöntemleri]({% post_url 2020-04-08-gradyan-yontemleri-ile-optimizasyon %}) yazımızda bahsettiğimiz şekilde, bu hata fonksiyonun en küçük noktası, $m$ ve $b$ değerlerine göre türevler alınıp sıfıra eşitlenerek bulunabilir.

$$
\begin{aligned}
\frac{\partial E(m,b)}{\partial m} &= \sum_i \left ( y_i x_i + b x_i + m x_i x_i \right ) = 0 \Rightarrow m = \frac{\sum_i x_i y_i - b\sum_i x_i}{\sum_i x_i x_i}\\
\frac{\partial E(m,b)}{\partial b} &= \sum_i \left( m x_i - yi + b \right ) = 0 \Rightarrow b = \frac{\sum_i y_i - m\sum_i x_i}{N}\\
\end{aligned}
\tag{1}
$$

Denklem $\eqref{1}$ de görüldüğü üzere, $m$ ve $b$ değişkenlerine en küçükleyen noktalar birbirine bağımlı olarak elde edilmektedir. Bu bağıntıdan kurtulmak için $b$ için bulunan en iyi değer $m$ için elde edilen denklemde yerine yazılırsa;

$$
\begin{aligned}
m &= \frac{\sum_i x_i y_i - b\sum_i x_i}{\sum_i x_i x_i}\\
&= \frac{\sum_i x_i y_i - \frac{1}{N} \left ( \sum_i y_i - m\sum_i x_i \right) \sum_i x_i}{\sum_i x_i x_i}\\
&= \frac{\sum_i x_i y_i - \frac{1}{N} \left(\sum_i y_i \sum_i x_i - m\sum_i x_i \sum_i x_i \right)}{\sum_i x_i x_i}\\
&= \frac{N \sum_i x_i y_i - \sum_i x_i \sum_i y_i}{N \sum_i x_i x_i - \sum_i x_i \sum_i x_i}\\
\end{aligned}
\tag{2}
$$

elde edilir. $m$ değeri çözüldükten sonra $b$ için elde edilen denklemde yerine yazılarak $b$ noktasını en iyileyen çözüm de bulunabilir. Yukarıda matematiksel ifadesi verilen uyumlama işlemi C dilinde ```void fit(matrix_t *sdata, void *model)``` fonksiyonu ile gerçeklenmiştir. Fonksiyon $N \times 2$ boyutunda verilen $N$ tane $(x_i,y_i)$ veri çiftini girdi olarak almakta ve sonuçları ```model ``` ile verilen bellek alanına yazmaktadır.

Yazılan fonksiyonun farklı veri setleri üzerinde çalıştırılması sonucunda aşağıda verilen sonuçlar elde edilmiştir. Verilen grafikte koyu yeşil noktalar $(x_i,y_i)$ veri çiftlerini, siyah doğru $(m=0.4, b=3)$ bu verilerin üretildiği referans doğruyu ve kırmızı doğru ise yazılan fonksiyonun çıktısını göstermektedir.

| Gürültüsüz Veri |  Az Gürültülü Veri | Orta Gürültülü Veri | Çok Gürültülü Veri |
:-------:|:----:|:----:|:---:|
![Doğru Uyumlama][linefit_example_n0] | ![Doğru Uyumlama][linefit_example_n1] | ![Doğru Uyumlama][linefit_example_n2] | ![Doğru Uyumlama][linefit_example_n3] |

Doğru uyumlaması testinde yöntemin gürbüzlüğünü analiz edebilmek için artan gürültü seviyelerinde 4 farklı veri kullanılmıştır. Şekilden de görüldüğü üzere yöntem düşük gürültülü veri setleri için gerçek doğruya oldukça yakın sonuçlar elde ederken artan gürültü seviyelerinde gürültülü veya aykırı verilerden oldukça etkilenerek hatalı sonuçlar üretmektedir.

### RANSAC Yöntemi

RANSAC yönteminin temel fikri; makine öğrenmesi aşamasında veri setinde bulunan örneklerin tamamının değil, rastgele seçilen alt kümelerinin (random sampling) kullanılmasına dayanmaktadır. Veri içerisinde aykırı ve gürültülü veriler gürültüsüz verilere kıyasla daha az olacağından, yeteri sayıda rastgele seçilen alt kümeler içerisinde gürültülü veya aykırı veri içermeyen bir alt küme elde edilecektir. Bu alt küme üzerinde eğitilen modelin veri setinde yer alan diğer verilerle de yüksek uyum (consensus) göstermesi beklenmektedir.

RANSAC yönteminde uyum ölçütü olarak, veri setinde yer alan tüm noktaların uyumlanan modele olan uzaklıkları ölçülmekte ve uzaklıkları $\tau$ eşik değerinden küçük olan noktaların sayısı uyum büyüklüğünü göstermektedir. Bu sayede, alt kümeler üzerinden eğitilen modellerden veriye en yüksek uyum sağlayan modelin seçilmesi ile gürültü ve aykırı veriden etkilenmeyen bir model bulunabilecektir.

Aşağıda çok gürültülü veri için rastgele seçilen 4 farklı alt küme için doğru uyumlama sonuçları gösterilmiştir. Verilen grafiklerde koyu yeşil noktalar veri çiftlerini, açık yeşil noktalar rastgele örneklenen ve model uyumlamasında kullanılan veri çiftlerini göstermektedir. Siyah doğru $(m=0.4, b=3)$ verilerin üretildiği referans doğruyu, kırmızı doğru yazılan fonksiyonun çıktısını ve kırmızı ile taralı alan ise uyumlanan modele uzaklığı $\tau=0.2$ den küçük olan noktalar kümesini göstermektedir.

| Rastgele Alt Küme 1 |  Rastgele Alt Küme 2 | Rastgele Alt Küme 3 | Rastgele Alt Küme 4 |
:-------:|:----:|:----:|:---:|
![Doğru Uyumlama][ransac_example_41] | ![Doğru Uyumlama][ransac_example_42] | ![Doğru Uyumlama][ransac_example_43] | ![Doğru Uyumlama][ransac_example_44] |

Şekilden de görüldüğü üzere 1,2 ve 3 numaralı alt kümeler üzerinden elde edilen model istediğimiz sonuçtan oldukça uzakken, 4 numaralı alt küme üzerinden uyumlanan model istediğimiz doğruya oldukça yakın bir sonuç üretmektedir. Burada uyumluluk ölçütü olarak kullanılan $\tau = 0.2$ eşik değerine göre birinci, ikinci ve üçüncü alt kümelerden elde edile modele göre 4 nokta, dördüncü alt kümeden elde edile modele göre ise 7 nokta uyum sağlamaktadır. Buradan da matematiksel olarak da 4 numaralı alt kümeden uyumlanan modelin en iyi model olduğu sonucuna ulaşılır.

Genel amaçlı bir makine öğrenmesi problemi için RANSAC yöntemi aşağıdaki algoritma adımları ile özetlenebilir.

> - **GİRDİLER**
>   - $D=\\{x_i,y_i : i=1,\dots,N\\}$: veri kümesi
>   - $K$: Rastgele seçilecek örnek sayısı
>   - $\tau$: Model ile veri arasındaki en büyük uzaklık
>   - $T$: İterasyon sayısı
> - **ÇIKTILAR**
>   - $M$: Uyumlanan model
>
> *****************************
>
> - EnYuksekUyum = 0
> - t = 0
> - **while** t++ < $T$
>   - $N$ veri-etiket çiftinden $K$ tanesini rastgele örnekle, $S = \left \\{x_k,y_k : k=1,\dots,K \right \\}$
>   - $K$ tane veri üzerinden model uyumlama gerçekleştir, `fit(S, Model)`
>   - $D$ kümesi ile model uyumunu hesapla, $u= \\#\left\\{x_i,y_i : \lVert \text{Model}(x_i) - y_i \lVert \leq \tau, i=1,\dots,N \right \\}$
>   - **if** $u$ > EnYuksekUyum
>     - $M$ = Model
>     - EnYuksekUyum = $u$
> - **return** $M$

Yukarıda verilen sözde kodda da görüleceği üzere, RANSAC yönteminin üç önemli parametresi bulunmaktadır. Bu parametreler $K$ her iterasyonda seçilecek örnek sayısı, $\tau$ uyumlanan model ile veriler arasındaki kabul edilebilir en büyük uzaklık ve $T$ iterasyon sayısıdır.

Her iterasyonda seçilecek örnek sayısının ($K$) alt sınırı verilen problemin analitik çözümü için gerekli en küçük veri sayısı olarak belirlenir. Örnek olarak doğru uyumlama için en az iki nokta gerektiğinden $K \geq 2$, perspektif dönüşümü için en az üç nokta gerektiğinden $K \geq 3$ olarak seçilmelidir. $K$ sayısının büyük seçilmesi $T$ iterasyon sayısını da artırdığında (açıklama aşağıda yapılmaktadır) genellikle seçimler alt sınıra eşit olacak şekilde yapılmaktadır.

$\tau$; uyumlanan model ile veriler arasındaki kabul edilebilir en büyük uzaklık, RANSAC yönteminde belirlemesi en zor parametrelerden biridir. Doğru uyumlama gibi basit bir problemde dahi eşik değeri veri görselleştirilmeden veya verideki gürültü oranı kestirilmeden bulunamamaktadır. Bu parametrenin seçimi için veri ön incelemeden geçirilmeli ve verinin birimine göre kabul edilebilir bir hata toleransı belirlenmelidir.

RANSAC yönteminin önemli bir diğer parametresi de $T$ iterasyon/rastgele örnekleme sayısıdır. Seçilmesi gereken iterasyon sayısı kullanılan verideki aykırı veri oranına ve istenilen başarı olasılığına bağlı olarak değişmektedir. Veride yer alan aykırı veri oranı $q$, model uyumlamada kullanılacak veri sayısı $K$ ve istenilen başarı oranı $p$ ile ifade edilmesi durumunda gerekli $T$ iterasyon sayısı aşağıdaki şekilde hesaplanır.

Örnekleme seçimleri birbirinden bağımsız varsayılırsa, $N$ veriden $K$ tane gürültüsüz veri seçme olasılığı = $(1-q)^K$ dir. Buradan, seçilen $K$ örnekte en az bir tane gürültülü veri olma olasılığı = $1 - (1-q)^K$ bulunur. Seçimin $T$ kez tekrarlanması durumunda, her seçimde en az bir gürültülü örnek bulunması olasılığı = $(1 - (1-q)^K)^T$ olarak hesaplanır. Bu olasılık aynı zamanda başarısızlık olasılığına da eşit olduğundan, $1-p = (1 - (1-q)^K)^T$ yazılabilir. Buradan da;

$$ T = \frac{\log(1-p)}{\log(1 - (1-q)^K)}$$

olarak hesaplanır. Aşağıda bazı örnek durumlar için gerekli iterasyon sayıları hesaplanmıştır.

| $q$ / $K$,$p$ | K=3, p=0.8 | K=3, p=0.99 | K=5, p=0.8 | K=5, p=0.99 | K=10, p=0.8 | K=10, p=0.99 |
|---------------|------------|-------------|------------|-------------|-------------|--------------|
|       0.1     |      2     |      4      |      2     |      6      |      4      |      11      |
|       0.2     |      3     |      7      |      5     |      12     |      15     |      41      |
|       0.3     |      4     |      11     |      9     |      26     |      57     |      161     |
|       0.4     |      7     |      19     |     20     |      57     |     266     |      760     |

Tablodan görüldüğü üzere gerekli iterasyon/örnekleme sayısı istenilen başarı oranına bağlı olarak hızla artmaktadır. Ancak, $K=10$ olarak seçilen bir problemde $q=0.4$ aykırı veri oranında dahi yöntem ortalama 760 iterasyon sonucunda $99\%$ olasılıkla doğru bir sonuç üretmesi beklenmektedir.

Yazıda yer alan analizlerin yapıldığı kod parçaları, görseller ve kullanılan veri setlerine [ransac_algorithm](https://github.com/cescript/imlab_ransac_algorithm) GitHub sayfası üzerinden erişebilirsiniz.

**Referanslar**
* Fischler, Martin A., and Robert C. Bolles. "Random sample consensus: a paradigm for model fitting with applications to image analysis and automated cartography." Communications of the ACM 24.6 (1981): 381-395.

[RESOURCES]: # (List of the resources used by the blog post)
[linefit_example_n0]: /assets/post_resources/ransac_algorithm/linefit_example_n0.svg
[linefit_example_n1]: /assets/post_resources/ransac_algorithm/linefit_example_n1.svg
[linefit_example_n2]: /assets/post_resources/ransac_algorithm/linefit_example_n2.svg
[linefit_example_n3]: /assets/post_resources/ransac_algorithm/linefit_example_n3.svg
[ransac_example_41]: /assets/post_resources/ransac_algorithm/ransac_example_41.svg
[ransac_example_42]: /assets/post_resources/ransac_algorithm/ransac_example_42.svg
[ransac_example_43]: /assets/post_resources/ransac_algorithm/ransac_example_43.svg
[ransac_example_44]: /assets/post_resources/ransac_algorithm/ransac_example_44.svg