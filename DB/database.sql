--
-- PostgreSQL database dump
--

-- Dumped from database version 16.1
-- Dumped by pg_dump version 16.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: adminpack; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION adminpack; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    dirty boolean NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    full_name text,
    username text,
    email text,
    phone_number text,
    gender text,
    password_hash text,
    confirmed boolean,
    confirmation_token text,
    role text
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schema_migrations (version, dirty) FROM stdin;
2	f
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, full_name, username, email, phone_number, gender, password_hash, confirmed, confirmation_token, role) FROM stdin;
1	Gary Sherman	tanyabryant	silvagerald@example.org	001-954-593-0698x368	male	05de3fb33b297539baa24baf6a422d38879d79dc4134b1ad9107ea78fd4c08dd	t	444080	user
2	Stephanie Oconnor	richardrice	rmontes@example.net	402-266-6737x7565	prefer not to say	3a3e5b3030d4d35d633a31e92fb11883aa41f493fde99214c86a924625c3d012	f	517647	admin
3	Nancy Rivers	dlee	jessicadunn@example.net	390.977.9026x1248	female	0e0c690035394a05478f17d66372cd2a19508b527984df4d4def345e54e6f0a6	t	253118	user
4	Kelly Perry	stephanie59	kimberlydavenport@example.org	9663539928	male	a9c0f4e018c2d5d84db374ff71ce6cfb8fb6971ed397f9b24d50abbb3733ba33	t	802882	admin
5	Angel Cole	phamkim	xporter@example.net	811-573-9351x634	prefer not to say	53f05ad048052b54044fa4e82b5ea52994beee4fb5b2e9f6f26697fca7ca0390	t	257641	admin
6	Melinda Nichols	patriciavaldez	ksmith@example.net	364.970.7271x2664	prefer not to say	7ad109746d961bf174ce60c509e00c76e37a2ae0c15e4d3d2096c1890ee162bf	t	181116	admin
7	Susan Hickman	ojames	gguerra@example.com	+1-805-556-2730x19611	prefer not to say	886814cb0adfc0601244e8c9658880f7aa39f3393fe25b282ca7555e3d1312f0	f	493132	admin
8	April Rocha	nharris	haley46@example.net	696-476-7954	prefer not to say	09daeb12325cd8945921ddc456bf75fb340037f60aedd4346dc758b5f6086459	t	823560	user
9	Patricia Strickland	chad31	dianagaines@example.org	(350)345-8264x924	male	fc6f19e039d399709b7b9b8ac60d3ae5a1c533ed6bcf94765d4cc4b591a277c3	f	690571	admin
10	Amy Wood	plawson	erik04@example.org	432-870-6574x51939	prefer not to say	d78c51cce2a2aad1164a4c9020d4282b403359d9725ee634db1a09edec072ce7	t	976424	admin
11	Whitney Maldonado	jacobcrawford	freypeter@example.com	322.843.3346	female	1c16258e4802838df4494ecc2f22c3c15cba344ba837190ab512afa351252673	f	645254	user
12	Kristen Rowland	patrickwatts	chaneykimberly@example.com	587.541.5719	female	0bd66d1e6ab7ee69290678174bfdc860c66fece4cb4f5b677391262f1542c2dc	f	372451	admin
13	Michele Clark	johnsonshelby	greenjennifer@example.net	001-337-710-2766	female	df62715fdefed0da5e00fccd41d83047b3054a16278ab2c07ca45f9610c941de	t	089424	admin
14	Jennifer Elliott	craigadrian	wmarsh@example.com	754.308.6833	prefer not to say	8be8c6ae820baa1984fd6921518bb86a283856ff45919f3a5631cbfc7e5c1ddf	t	068731	user
15	Tyler Burns	awilcox	smithholly@example.net	775.984.9316x5925	male	b51f5b8c3acfb59d09f9b753875dab63352efa6b50a3086920cf28680d01a440	t	844603	user
16	Wanda Santana	mtaylor	higginsnathan@example.org	(226)214-8590x2772	male	6e9e5293e622c1a8496a1147f5c7724a2e1ddb145b3213e442eaafdf51b26b43	f	511036	admin
17	Daniel Rubio	dbanks	tracy78@example.com	+1-671-719-9703x04569	male	224fc9e8fe6dd1052edd867c76a247655166142029284e4c28807a540044a130	t	751924	user
18	Cathy Jackson	johncruz	mitchellgray@example.net	(632)235-9996	female	1712fc8cc13f52588021fd51ed60f28cc68a972177b357130abb67bbd9b6f6ba	f	934813	admin
19	Jennifer Martinez	markhall	kaylaromero@example.com	401-602-7722x3236	male	29f74b534ae29f57e8e06b634264e6db177ffcc8b45a5f23b04df7a28ee2106f	f	876152	admin
20	Mary Parks	laura20	oconnelldenise@example.net	790.247.3384	female	db6d30b080daffd02a5bf399792a1051988b29e36d10d5d3820bcecf4c048ba0	f	572637	admin
21	Adam Solis	teresa99	christopher19@example.com	001-398-302-7766x900	prefer not to say	d2adecc1b0d406fdfa00977d6a9d4023325f7a6044df28d8b0b1a74cdf3732a3	t	475780	admin
22	Kenneth Neal	taylorthomas	nancy27@example.net	7846955474	prefer not to say	da519e501855a2e406e1dcfd3390c6f1902511f74b444cec5f7a0b0679242319	t	947083	admin
23	Gary Smith	michelle61	wellsedward@example.net	001-855-675-2944x20882	prefer not to say	6c4d27262a0b51a73e91f6daf3b8275125bbed30f97bf48c4e1aa543cf8ecffb	t	736264	user
24	Patricia Jones	christopher59	wthomas@example.org	(802)927-8112x93375	male	68a5c7e4066134410a26d6e27b8830c04710242460859d62b9a11b53b5782814	t	789415	admin
25	Jennifer King	sdiaz	greenpatrick@example.org	891-973-5895	female	184347de65652bfeb4b5dffd5818fd0357d05e87eb577a8f6b94ee247d2a7f4c	t	257475	admin
26	Ryan Hudson	robersonamy	desiree76@example.org	001-406-860-8291	prefer not to say	67ef1f2bfde396fdacd82c81b0d39455c7cfd763f6c2d06262a56b6f3020c557	t	789250	admin
27	Alfred Lopez	xromero	zcampbell@example.net	+1-826-528-6752x657	male	aec94d14ced5f37d9c76b81d46908154eb46e657662988ac205c6747078482dd	t	861123	admin
28	Miguel Maddox	abrown	sharonhardy@example.org	314-639-8062x029	male	9d9b82d04495f978db7e5497cf04746aa8118dbc01fc8889f42cbd2d8c4e6623	t	173005	admin
29	Briana Mata	jeffreydavid	christinenorman@example.net	952.835.3709x24964	prefer not to say	4298877361b28d76207f649503d6fd92435169217213a79def5e73137fdb28a0	f	051905	user
30	Vincent Smith	christopherberry	ohoffman@example.org	+1-779-352-7215	prefer not to say	1275355e9a3f62b0707114d2efbcd8767385e594d4189fe2975794adf08041f3	f	832838	user
31	Lauren Martin	cartercarol	wlane@example.org	(375)939-7186	female	0b8554a1127f6ea5ff4a52c7240cfad8d4ba5d318e55374f97df1ca12af72062	f	872789	user
32	John Gordon	jacobarnold	april80@example.net	2869852384	prefer not to say	d5b4b0936a9fee5088898d64921fa8a922cb8dec1968eeea6da078328d36f488	f	545396	admin
33	Christine Clarke	kennethrandall	daniel00@example.org	934-978-3249x95569	male	629ec7f09b9ef7ac8d9255d707b0722fda5ec5fffd801398e6397f8cf2caf684	t	098421	admin
34	Kimberly Lamb	evansjesse	nancy71@example.net	501.559.9289x821	female	47ce342c78d4d09afe9146e4f1f9e2b0177897654b031873d2b1a4e03a07f4a7	t	904977	admin
35	Jeffrey Hurley	edwardbenton	jzamora@example.org	+1-613-878-8191x67404	prefer not to say	21d721443755a194306f2e30ddbdb011cacea8f1f53214aafe5a194b9f5a2c60	f	208347	user
36	Lauren Ferguson	wrodgers	yrodriguez@example.net	950.633.1812x7349	prefer not to say	1661eb266122588d069cf8f5d6d49cf073b2e3c8fac9ababc3537a5af2302b2e	t	475049	admin
37	Chelsey Brooks	matthewpearson	sethnewman@example.net	611-534-8337	female	497717b5c0491ecb7ef7e5469c51cfb3deab1c4895dc10d40f196f0ca36b6f72	f	154564	user
38	Gregory Hart	lindsaywhite	melissawilliams@example.org	513.438.2263x769	female	e70849a21ea0972e96531f981396fca2ce4dfe02c6884eeffcedba9ff2ff911b	t	174158	user
39	William Castro	melissamcbride	derrick37@example.com	001-936-522-6574x107	male	4106b4f6c92d5e243159ffc5553c5ed481d627148d7f96362c744c3bef917518	t	379086	admin
40	Hannah Thomas	hartcourtney	kimberlymartinez@example.com	377.945.6833x44549	female	163bde1f3f6cceac546b9520ded56e53ee9e693f6200f7e2bd3123d19f39e363	f	999670	admin
41	Paul Carpenter	rodriguezbrian	lthompson@example.org	225.218.2130x8199	prefer not to say	25bd9a880f1de44cb82b1b3ba67b0feecf304c6a47174da3017c9fa616289286	t	525561	admin
42	Shane Watson	juan95	xjohnson@example.net	+1-698-728-6871x042	male	5313ec38cb37dbfe9083edb16252327d04503579e1c8d4495a27ee83d64be054	f	253771	user
43	Sarah James	peterhutchinson	elizabethleonard@example.net	001-700-716-4663x5253	prefer not to say	51c7cfa440e4300539571471420f5aeb7318bbdd503610067809b42af9d7fd4a	t	372123	user
44	Ronald Gates	bwilliamson	mariathompson@example.com	(958)310-6123	prefer not to say	df76563c50d8fdad1651fc377aabae8359fa48184d4ff4437dda564d74d4f5a9	t	717670	user
45	David Rice	mathewseric	markcoffey@example.org	728-623-4927x069	male	7a02eec5db30742af7f70ded5fcb4c69dbf3f55018cc1a6cd0c77d12caea4b17	f	088472	admin
46	Ann Mills	richardwallace	iknox@example.net	+1-820-904-9285x2518	male	ed22b41f6542e5b7c15ceb5e05216af7eb5afaed525af14d63c1505e197ebead	f	881219	user
47	Christine Flores	nicolemiller	amiller@example.com	(551)795-3365	prefer not to say	7b5339ca1d8ec68ba81fbfe0896a9e50eb33b44ee3ebfbb2014f362d1d13d834	t	295173	user
48	Shawn Brown	sharpdawn	yscott@example.org	3866363917	female	ec8331dae48aafc27a6834906b6c3e0d2e81f4f1e8bf4ee92f69b0e650ba4ab5	t	885920	admin
49	Sherri Thomas	squinn	wigginsneil@example.com	+1-926-635-0331x856	male	e0d802c8a2dae8a2e3d5705c96e0e5aea20baa7e6a28c98d32d4db14c8791293	t	686917	user
50	Susan Carter	jesus92	bromero@example.org	001-812-635-2256	male	6d6104dbe29e04b01561e45e97aed54c0e7c7d1a68bd9ce862c85a7adf57f47a	t	751344	admin
51	Jessica Morgan	belldale	erica75@example.net	864.612.6093x892	male	003d1d1d7df8c6414de5e6a2add406955b77052244714f7f2900513b6c65e239	t	919876	user
52	Brent Hess	ywoods	ruiznicole@example.net	+1-214-468-8331x9772	prefer not to say	3b7a19bbc619010d92f120dd37f72535d396fbf1b8cd0c57f405a67c0eeec4c4	t	280635	admin
53	Timothy Quinn	jonesmichael	pbooker@example.net	(256)956-9584x9697	male	3bf2f08b993d0d6c92010b1d1bc39f8b7d42010fe4bec24623e009fa01e489f9	f	892859	user
54	Debra Gould	sandersjustin	pgarcia@example.net	(939)741-5597	male	1f3e9506f072ab5d0397291c49f3dc927f38b30538ce92ff8d1a6a05668628a5	f	899431	admin
55	John Ferguson	brian23	evansruth@example.org	856.241.6617x08994	female	8c7115c100df0067b8878c3258b33c81a5cc62f1f8f902804488f1c61b876988	f	169115	admin
56	William Gaines	martinchristopher	kathleendiaz@example.com	001-615-926-9021	female	27e276fdf9caf5eda9671f883988346b464a78652ae605a66dd365661ab08f57	t	277635	user
57	Jeanette Alvarado	phillipssamantha	wilsonkelly@example.org	705-543-6573x6674	female	ee9e141a58c04960f481123fff581dec1d86ab36b5964b533ff781cf131847af	t	391090	user
58	John Vega	melendeztheresa	imyers@example.net	(438)889-8104	female	62a4a48ee198d25f62cb81a7ccb263688bac4df9977c5a135c98c6a5d7c658bf	t	908160	admin
59	Melissa Rodgers	sandramoore	cprice@example.net	482-644-3423	male	78da052e042b9ebbb87b3b838b5042c58e4daf4597fc68a486ba04e499c8ba7d	f	816049	user
60	Heather Casey	cindy27	christine27@example.org	(963)418-6360x414	prefer not to say	2860014173cf580711774680a0c5686ea24446b86b3d2e57a3b20d6cbd319ed3	f	020473	user
61	Ronnie Mcgee	jonesisabella	thomasjohn@example.net	427.509.8739	prefer not to say	5be06caffe5797d16d2ce12664e4fb15f2a1e9ff8ad2ae994bff01d49fa42052	t	474282	admin
62	Dr. Jeffery Fleming	ovasquez	amanda85@example.net	001-455-845-0100	female	638907dbdf42acd114cbbd114c56b64797d80ae19044994d903e6abeddb5edd2	f	611064	admin
63	Karen Klein	jeremyroberts	calvinyoung@example.net	(816)808-5039	female	99696d5dec9026455edf676d418c6027a22fdfa8b5d65dd14c10f9cddaf446fb	t	079942	admin
64	Jasmine Ramirez	wsanders	maureenthompson@example.net	001-890-602-0253x3646	male	0f573145b544c201dc8bcf41c324c8702003e12509b078323d618abbfe56b7d5	f	795377	user
65	Elizabeth Johnson	christopherjackson	floresjessica@example.com	609-765-1737	female	62766e0ef944f15f488244fc0ac80ce5580cd8e43295c249ac30167c297ca6e9	f	597325	admin
66	Brandon Daniels	franklinkerr	frederick85@example.org	001-604-332-8977	male	f9a6a5ce0dd840a0fc620e51e9e0aff2ad8aa38e73c09e4a174afbbe779ae807	t	789714	admin
67	Kristen Johnson MD	adamshailey	oscarwilliams@example.net	(226)888-9695x712	female	ac43957b9197895914ed0f1c0961421adfc43534ee64191e82864a9b09d2f4ca	t	605595	user
68	Dr. Ian Wong	james17	ubrown@example.com	867.578.0760	female	219b200c2062f119e23eedb1c007f1b6dae3dabe43f77d85400502cd6c4bad32	t	079253	admin
69	Katrina Mckenzie	michaelwilliamson	bryan50@example.net	+1-445-568-9827x0695	female	433ec1c95f2d3aad5dd7e0e4838106d9ff1102295466e7b980dbb183d6595963	t	535453	admin
70	Kenneth Conner	afitzpatrick	kevin74@example.net	001-281-838-7822x53636	female	8072aa73d3fb8b12e474d09e66b32c071ba2d9bb1694366e6ff4ea61b1b42b51	t	624370	admin
71	Alexandra Jacobson	pmartin	lrobinson@example.org	+1-676-619-7582	prefer not to say	b24eabba0106dacac0d6702a18fa9385c5c3a7280886b7f512eb20ad14855724	t	117631	user
72	Theresa Campbell	erik45	yvonne99@example.net	+1-356-326-2802x2191	male	49bd10244c2e69bf7930f86451d060ac598b358954df57b5124cc866a4bab51e	t	877110	admin
73	Leslie Lloyd	cweaver	hamiltonmelinda@example.org	001-867-328-5799x0647	male	983577a74b602ac8e69ae0dd2965c3c2df2343b0d26c540d52f13f695a12fdb9	t	476422	admin
74	Preston Gates	dustinmorrison	jessica34@example.com	(900)755-5570x9635	male	620cdc23a428e3d0055e5cce11988e0920ffadcc78c3eeee4df99f51f41b4078	t	310701	admin
75	Connor Garcia	jacobcook	sanchezdavid@example.net	(311)238-1388x331	female	da1e3fa989c55b5c8b4527eb43ebc354aa74dbe169127df801a09c7ef0cd5bbb	t	028743	user
76	Jacob Martin	edwardvalenzuela	melissalynn@example.net	6476845285	female	2aa3a7faab32515be36993b114ad62d450a32b19f072b82ed65c7861f19df457	f	471071	admin
77	Jose Burch	wthompson	smithlonnie@example.com	213-287-8007x281	female	e61e729579bdd5822524bf05af7553ec98761b8a6fb26042e395b30147236a34	t	148823	admin
78	Victoria Grant	htorres	russellsteven@example.org	(818)739-5701	prefer not to say	ad591b6895f9b7a2a8e9161b71a36f6cea456f6f7a3db8c2cd454956098958fa	f	792678	admin
79	Jason Gonzalez	vmorgan	jasmine69@example.net	(245)762-3862x89147	male	511494fdbfee014afb1a8cee0e5762b466e35a3e2e451799cf5d7ad681919b5b	t	481707	admin
80	Jeffery Roach	ian50	stewartdana@example.org	+1-612-229-0532x5536	female	8dc0efd4dd6174b57faa94999a80fdca88c1f7a6431e6ec1dc1e1537e0159fac	t	175048	user
81	Lisa Ramirez	daisy89	richardsonbarbara@example.org	+1-754-712-6990x494	female	b8928763ca2f4f2a8745a1c384143259643ddc33524bb1030171a4b55d05f298	f	971198	user
82	Jocelyn Blackburn	williamsvictor	joseclark@example.com	8852421094	male	02652faf74468e7c3c663e3b1f9672c692939fb7b3258a4d89d2ffd423ac08b3	f	871667	user
83	Amy Reilly	khale	rebecca73@example.com	978.782.9755	male	0ddcc29d0a72efff9f49b3b2956bbf97bb9500be4ff3a9412d5eaf1e2253c0f2	f	996021	user
84	Frederick Hurley	gary19	henry14@example.com	(810)716-3659x975	female	9014b067c6db23865806d7310257428db80f1e00e4230cfeaf501dab477b264f	f	999736	user
85	Deanna Perez	tasha68	jonesjeffrey@example.com	+1-249-966-5631	male	f90b9cfc8bf7cd9a76afed55ca79b624a1f72a87eecfb141884b02be8a4250e3	t	542336	user
86	Andrea Davenport	aross	deanna29@example.net	+1-584-580-1930	female	629f33e9d64f6083830cf5f9320edad805ad367b5e36648b29787e12fd3d2644	t	388557	user
87	Tim Rivera	maynardsavannah	floresjennifer@example.com	+1-872-374-8334	male	778b982c9457ed91e524f912f0760dffe8473fff4138d425766add54aa8591ad	f	692170	user
88	Mark Barry	georgeashley	troyrogers@example.com	685-910-3193	female	21c19d5beadb177e181e1ba93575216c52f2fa167c361bbfc190dfb1d5881ba1	t	562231	user
89	Mr. Joshua Jacobs	theresa28	travisjoseph@example.net	697.593.9303	prefer not to say	179d9130756bb0dca82dbf23a01c906ad8ba7eb8373dedccaa2e778b63af54f4	t	887526	admin
90	Alicia Camacho	qhuff	ehendricks@example.org	(402)883-6162x8522	female	e9d54e18935da104764f08fa7c20d0bdaf05d7e436963b26b5160f8479672d0a	f	679607	admin
91	Mr. David Miller	rachel25	robert77@example.com	6105896556	male	280e84eae6d9fccd3505516c2c3208dc509a559fcbf95e9fff1ba1ef86fe6c34	f	922599	user
92	Cody Krueger	qrodriguez	cunninghambrandon@example.com	351-246-5430	prefer not to say	a0fd5d81214c588c22f9c8ee6f116a9925f4d2c1f6eae7ebeb0ebccf07f8c2b8	f	972801	admin
93	Steven Wilson	parkerlaura	derrick58@example.com	7739798799	female	60c31462e0070093c424346602b6db27a1f204293ad3b435bdd1771f64d8ade7	f	555185	user
94	Crystal Hughes	alyssasalas	speters@example.net	(465)984-8249x62615	prefer not to say	fc790d5bc36915436233aebcb352df0d917a2ec012b3bcdf1c21b18b6e231c37	t	513619	user
95	Christopher Turner	warnold	lmeyers@example.net	898.965.0577	male	c6e0463a41c1c7cddcf766b0395fbdd0a6a6cbcbd4a2661c747bbda03023edaf	f	448945	admin
96	Taylor Lin	martinkimberly	jennifer86@example.org	(724)513-7972	prefer not to say	d56e8ee116cd29b7725d42bc809d64b19ada7ee4529b618bc2b9f2c6865faa75	f	245391	user
97	Bobby Fisher	xhayes	garciamichael@example.net	001-229-512-4333x0871	male	0c593427e35743e31fe2be79942a06983663d78fdd2455ac11849fd4dd95fdc5	f	124987	admin
98	Walter Green	aliciabeck	jonesjoshua@example.com	+1-832-976-4080	male	f8e685a63c5dc071d99e924dc70c78da8baf5bb58720474738f61d34d15895e1	f	549460	user
99	Glenn Adams	kimjohn	smithcynthia@example.net	942.235.5011	female	a6fef807a73f6b014fc49339b61e66f01f93af33075df314e52e39f9c0eff156	f	089642	admin
100	Melody Mercado	chambersbrian	brandonkhan@example.com	001-549-246-8022x919	male	8ffdac76d4f54891bef47820f8973b88e267b55972ce8d1f2c2601d8ebf0975f	t	124269	admin
101	Botagariyev Amirhan	Rubylliez	user2@adv.com	+77767522895	dot-1	$2a$10$gsOUTmHzCtrn/JBZiE.e2.q.5AIXnvtEr.MXNboGcSTuQmPNGx3b2	t	048039	admin
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 101, true);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_confirmation_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_confirmation_token_key UNIQUE (confirmation_token);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_phone_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_number_key UNIQUE (phone_number);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- PostgreSQL database dump complete
--

