git checkout. /home/smartinez/freebsd-src/tests/sys/common/vnet.subr

atf_test_case v4 cleanup
v4_head()
{
	atf_set descr 'ping fib test'
	atf_set require.user root
}

v4_body()
{
	vnet_init
	epair=$(vnet_mkepair)
	ifconfig ${epair}a 192.0.2.2/24 up
    vnet_mkjail alcatraz ${epair}b
    jexec alcatraz sysctl net.fibs=5
    jexec alcatraz ifconfig ${epair}b fib 1
    jexec alcatraz ifconfig ${epair}b 192.0.2.1/24 up
    atf_check -s exit:0 -o save:std.out -e empty \
		jexec alcatraz ping -F 1 -c 1 -t 1 -S 192.0.2.1 192.0.2.2
}

v4_cleanup()
{
	vnet_cleanup
}

atf_test_case v6 cleanup
v6_head()
{
	atf_set descr 'ping6 fib test'
	atf_set require.user root
}

v6_body()
{
	vnet_init
	epair=$(vnet_mkepair)
	ifconfig ${epair}a inet6 fd46:6694:6228::1/48 up
    vnet_mkjail alcatraz ${epair}b
    jexec alcatraz sysctl net.fibs=5
    jexec alcatraz ifconfig ${epair}b fib 1
    jexec alcatraz ifconfig ${epair}b inet6 fd46:6694:6228::2/48 up
    atf_check -s exit:0 -o save:std.out -e empty \
		jexec alcatraz ping6 -F 1 -c 1 -t 1 -S fd46:6694:6228::2 fd46:6694:6228::1
}

v6_cleanup()
{
	vnet_cleanup
}

atf_init_test_cases()
{
	atf_add_test_case v4
	atf_add_test_case v6
}
