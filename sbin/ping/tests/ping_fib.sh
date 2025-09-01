#-
# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (c) 2020 Ahsan Barkati
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
#

require_ipv4()
{
	if ! getaddrinfo -f inet localhost 1>/dev/null 2>&1; then
		atf_skip "IPv4 is not configured"
	fi
}

. $(atf_get_srcdir)/utils.subr

atf_test_case "basic_fib_v4" "cleanup"
basic_fib_v4_head()
{
	atf_set descr 'ping fib test'
	atf_set require.user root
	atf_set require.progs jail jq
}

basic_fib_v4_body()
{
	epair=$(vnet_mkepair)
	ifconfig ${epair}a 192.0.2.2/24 up
	vnet_mkjail alcatraz ${epair}b
	jexec alcatraz sysctl net.fibs=5
	jexec alcatraz ifconfig ${epair}b fib 1
	jexec alcatraz ifconfig ${epair}b 192.0.2.1/24 up

	require_ipv4
	atf_check -s exit:0 -o save:std.out -e empty \
	    ping -F 1 -c 1 -t 1 -S 192.0.2.2 192.0.2.1
	check_ping_statistics std.out $(atf_get_srcdir)/ping_fib_1.out

}

basic_fib_v4_cleanup()
{
	vnet_cleanup
}

atf_init_test_cases()
{
	atf_add_test_case "basic_fib_v4"
}
